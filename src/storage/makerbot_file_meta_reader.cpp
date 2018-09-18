// Copyright 2017 MakerBot Industries
//#include <boost/log/trivial.hpp>
#include "storage/makerbot_file_meta_reader.h"


MakerbotFileMetaReader::MakerbotFileMetaReader(){
  Init("");
}


MakerbotFileMetaReader::MakerbotFileMetaReader(const std::string &kFilePath){
  Init(kFilePath);
}


MakerbotFileMetaReader::MakerbotFileMetaReader(const QFileInfo &kFileInfo){
  Init(kFileInfo.absoluteFilePath().toStdString());
}


void MakerbotFileMetaReader::Init(const std::string &kFilePath){
  loaded_meta_data_ = loaded_small_thumbnail_ = loaded_medium_thumbnail_ =
  loaded_large_thumbnail_ = false;
  has_empty_file_path_ = kFilePath.empty();
  tiny_thing_ = new LibTinyThing::TinyThingReader(kFilePath);
  meta_data_ = new LibTinyThing::Metadata;
}


MakerbotFileMetaReader::~MakerbotFileMetaReader() {
  delete tiny_thing_;
  delete meta_data_;
}


// check validity
bool MakerbotFileMetaReader::isValid() {
  return (!has_empty_file_path_ && tiny_thing_->isValid());
}


// Like isValid but only checks for a metafile - necessary for the DRM hack
// where Kaiten gives us the location of a zip file that only contains
// a metadata file, no thumbnails or toolpaths.
bool MakerbotFileMetaReader::hasMetadata() {
  return (!has_empty_file_path_ && tiny_thing_->hasMetadata());
}


bool MakerbotFileMetaReader::hasJsonToolpath() {
  return tiny_thing_->hasJsonToolpath();
}


QImage& MakerbotFileMetaReader::getSmallThumbnail() {
  if(!loaded_small_thumbnail_){
    loaded_small_thumbnail_ = true;
    if(tiny_thing_->unzipSombreroSmallThumbnailFile()) {
      std::string thumb_file_content_str;
      tiny_thing_->getSombreroSmallThumbnailFileContents(&thumb_file_content_str);
      small_thumbnail_ = QImage::fromData(
      reinterpret_cast<const unsigned char*>(thumb_file_content_str.c_str()),
        thumb_file_content_str.size());
    }
  }
  if(small_thumbnail_.isNull())
    small_thumbnail_ = QImage(":/img/file_no_preview.png");
  return small_thumbnail_;
}


QImage& MakerbotFileMetaReader::getMediumThumbnail() {
  if(!loaded_medium_thumbnail_){
    loaded_medium_thumbnail_ = true;
    if(tiny_thing_->unzipSombreroMediumThumbnailFile()) {
      std::string thumb_file_content_str;
      tiny_thing_->getSombreroMediumThumbnailFileContents(&thumb_file_content_str);
      medium_thumbnail_ = QImage::fromData(
        reinterpret_cast<const unsigned char*>(thumb_file_content_str.c_str()),
        thumb_file_content_str.size());
    }
  }
  if(medium_thumbnail_.isNull())
    medium_thumbnail_ = QImage(":/img/makerbot_logo_110x80.png");
  return medium_thumbnail_;
}


QImage& MakerbotFileMetaReader::getLargeThumbnail() {
  if(!loaded_large_thumbnail_){
    loaded_large_thumbnail_ = true;
    if(tiny_thing_->unzipSombreroLargeThumbnailFile()) {
      std::string thumb_file_content_str;
      tiny_thing_->getSombreroLargeThumbnailFileContents(&thumb_file_content_str);
      large_thumbnail_ = QImage::fromData(
        reinterpret_cast<const unsigned char*>(thumb_file_content_str.c_str()),
        thumb_file_content_str.size());
    }
  }
  if(large_thumbnail_.isNull())
    large_thumbnail_ = QImage(":/img/makerbot_logo_320x200.png");
  return large_thumbnail_;
}


bool MakerbotFileMetaReader::loadMetadata() {
  bool success = false;
  if(tiny_thing_->unzipMetadataFile()) {
    auto error = tiny_thing_->getMetadata(meta_data_);
    if(error != LibTinyThing::TinyThingReader::kOK) {
      //BOOST_LOG_TRIVIAL(info) << "qtinything fails to load metadata: "
      //                        << static_cast<int>(error)
      //                        << ", default constructing";
      meta_data_ = new LibTinyThing::Metadata();
    }
    else
      success = true;
  }
  else {
    //BOOST_LOG_TRIVIAL(info) << "qtinything couldn't unzip metadata";
  }
  loaded_meta_data_ = true;
  return success;
}

