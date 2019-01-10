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
  bool is_cancelled_, dont_copy_if_dst_exists_;
  double copy_progress_;
  QFile src_qfile_, dst_qfile_;
  uint64_t src_file_size_, num_byte_writen_, buffer_size_;
  std::vector<char> copy_buffer_;

  public:
    ProgressCopy(const QString src_file_path = "",
                 const QString dst_file_path = "",
                 const bool dont_copy_if_dst_exists = false,
                 const uint64_t buffer_size = 65536) :
                 src_qfile_(src_file_path),
                 dst_qfile_(dst_file_path),
                 dont_copy_if_dst_exists_(dont_copy_if_dst_exists),
                 buffer_size_(buffer_size),
                 is_cancelled_(false),
                 copy_progress_(0.0),
                 num_byte_writen_(0) { }

    void setSrcDstFiles(const QString src_file_path,
                        const QString dst_file_path) {
      src_qfile_.setFileName(src_file_path);
      dst_qfile_.setFileName(dst_file_path);
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
        emit progressChanged(copy_progress_);
      }
    }

  public slots:
    void process() {
      if (dont_copy_if_dst_exists_ && QFileInfo(src_qfile_).exists()) {
        emit finished(true); // TODO(sam) do a binary comparison?
        return;
      }
      if (!src_qfile_.open(QIODevice::ReadOnly)) {
        qDebug() << "could not open source file, aborting";
        emit finished(false);
        return;
      }
      src_file_size_ = src_qfile_.size();
      if (!dst_qfile_.open(QIODevice::WriteOnly)) {
        qDebug() << "could not open destination file, aborting";
        // maybe check for overwriting and ask to proceed
        emit finished(false);
        return;
      }
      if (!dst_qfile_.resize(src_file_size_)) {
        MP_QINFO("could not resize destination file, aborting")
        emit finished(false);
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
          src_qfile_.read(copy_buffer_.data(), num_byte_to_write);
          dst_qfile_.write(copy_buffer_.data(), num_byte_to_write);
          num_byte_writen_ += num_byte_to_write;
          src_qfile_.seek(num_byte_writen_);
          dst_qfile_.seek(num_byte_writen_);
          setProgress(static_cast<double>(num_byte_writen_) / src_file_size_);
          // std::this_thread::sleep_for(std::chrono::milliseconds(10));
          QMetaObject::invokeMethod(this, "iterate", Qt::QueuedConnection);
        } else {
          emit finished(true);
          return;
        }
      } else {
        if (!dst_qfile_.remove()) {
          MP_QINFO("failed to delete destination file")
        }
        emit finished(false);
      }
    }

    void cancel() {
      is_cancelled_ = true;
    }

  signals:
    void finished(bool);
    void error(QString err);
    void progressChanged(double);
};

#endif // __PROGRESS_COPY__
