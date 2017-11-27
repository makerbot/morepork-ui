// Copyright 2017 MakerBot Industries

#ifndef __MB_FILE_META_READER__
#define __MB_FILE_META_READER__

#include <memory>
#include <string>
#include <QImage>
#include <QFileInfo>
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/reader.h>
#include "tinything/TinyThingReader.hh" // TinyThingReader, Metadata


class MakerbotFileMetaReader {
  void Init(const std::string &kFilePath);

  LibTinyThing::TinyThingReader *tiny_thing_;
  bool loaded_meta_data_;
  bool loaded_small_thumbnail_;
  bool loaded_medium_thumbnail_;
  bool loaded_large_thumbnail_;
  bool has_empty_file_path_;

  QImage small_thumbnail_, medium_thumbnail_, large_thumbnail_;

  public:
    LibTinyThing::Metadata *meta_data_;

    MakerbotFileMetaReader();
    explicit MakerbotFileMetaReader(const QFileInfo &kFileInfo);
    explicit MakerbotFileMetaReader(const std::string &kFilePath);
    ~MakerbotFileMetaReader();
    bool loadMetadata();
    bool isValid();
    bool hasMetadata();
    bool hasJsonToolpath();
    QImage& getSmallThumbnail();
    QImage& getMediumThumbnail();
    QImage& getLargeThumbnail();
};

typedef std::shared_ptr<MakerbotFileMetaReader> TinyThingPtr;

#endif  // __MB_FILE_META_READER__

