// Copyright 2019 MakerBot Industries.

#ifndef UI_SETTINGS_H_
#define UI_SETTINGS_H_

#include <QDebug>
#include <string>

#include "logging.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;
using json_pointer = nlohmann::json::json_pointer;

class UISettings {
  public:
      UISettings(const std::string default_file,
                 const std::string override_file);
      QString getStrValue(const std::string &key);
      int getIntValue(const std::string &key);
      bool getBoolValue(const std::string &key);
      float getFloatValue(const std::string &key);
      template <typename DATA_T>
      void setValue(std::string key, DATA_T val) {
          try {
              cached_settings_.at(keyToJsonPointer(key)) = val;
          } catch (json::out_of_range& e) {
              LOG(error) << "Invalid key provided for cached settings..." << e.what();
          }
          writeSettings();
      }
  private:
      std::string default_file_, override_file_;
      void initialize(void);
      bool fileExists(std::string file_name);
      void writeSettings();
      void mergeSettings();
      json_pointer keyToJsonPointer(std::string key);
      json cached_settings_, override_settings_;
};

#endif /* UI_SETTINGS_H_ */
