#ifndef __PROGRESS_COPY__
#define __PROGRESS_COPY__

#include <QObject>
#include <QFile>
#include <QtCore>
#include "error_utils.h"


class ProgressCopy : public QObject {
  Q_OBJECT
  Q_PROPERTY(double progress READ progress
             WRITE setProgress NOTIFY progressChanged)
  bool is_cancelled_;
  double copy_progress_;
  QFile src_file_path_, dst_file_path_;
  uint64_t src_file_size_, num_byte_writen_, buffer_size_;
  std::vector<char> copy_buffer_;

  public:
    ProgressCopy(const QString src_file_path = "",
                 const QString dst_file_path = "",
                 const uint64_t buffer_size = 1024 * 1024) :
                 src_file_path_(src_file_path),
                 dst_file_path_(dst_file_path),
                 buffer_size_(buffer_size),
                 is_cancelled_(false),
                 copy_progress_(0.0),
                 num_byte_writen_(0) { }

    void setSrcDstFiles(const QString src_file_path,
                        const QString dst_file_path) {
      src_file_path_ = src_file_path;
      dst_file_path_ = dst_file_path;
    }

    void setCopyBufferSize(const uint64_t buffer_size) {
      buffer_size_= buffer_size;
    }

    double progress() const {
      return copy_progress_;
    }

    void setProgress(double p) {
      if (p != copy_progress_) {
        copy_progress_ = p;
        emit progressChanged();
      }
    }

  public slots:
    void process() {
      if (!src_file_path_.open(QIODevice::ReadOnly)) {
        qDebug() << "could not open source file, aborting";
        emit finished();
        return;
      }
      src_file_size_ = src_file_path_.size();
      if (!dst_file_path_.open(QIODevice::WriteOnly)) {
        qDebug() << "could not open destination file, aborting";
        // maybe check for overwriting and ask to proceed
        emit finished();
        return;
      }
      if (!dst_file_path_.resize(src_file_size_)) {
        MP_QINFO("could not resize destination file, aborting")
        emit finished();
        return;
      }
      copy_buffer_.resize(buffer_size_);
      QMetaObject::invokeMethod(this, "iterate", Qt::QueuedConnection);
    }

    void iterate() {
      if (!is_cancelled_) {
        if (num_byte_writen_ < src_file_size_) {
          uint64_t num_byte_remaining = src_file_size_ - num_byte_writen_;
          uint64_t num_byte_to_write = num_byte_remaining > buffer_size_ ?
                                       buffer_size_ : num_byte_remaining;
          src_file_path_.read(copy_buffer_.data(), num_byte_to_write);
          dst_file_path_.write(copy_buffer_.data(), num_byte_to_write);
          num_byte_writen_ += num_byte_to_write;
          src_file_path_.seek(num_byte_writen_);
          dst_file_path_.seek(num_byte_writen_);
          setProgress((double)num_byte_writen_ / src_file_size_);
          QMetaObject::invokeMethod(this, "iterate", Qt::QueuedConnection);
        } else {
          emit finished();
          return;
        }
      } else {
        if (!dst_file_path_.remove()) {
          MP_QINFO("failed to delete destination file")
        }
        emit finished();
      }
    }

    void cancel() {
      is_cancelled_ = true;
    }

  signals:
    void finished();
    void error(QString err);
    void progressChanged();
};

#endif // __PROGRESS_COPY__
