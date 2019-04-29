// Copyright 2019 MakerBot Industries.

#include <sys/stat.h>
#include <fstream>  // NOLINT(readability/streams)
#include <iomanip>
#include "ui_settings.h"

UISettings::UISettings(const std::string default_file,
                       const std::string override_file) 
    : default_file_(default_file),
      override_file_(override_file) {
    initialize();
}

void UISettings::initialize() {
    std::ifstream file_strm_1(default_file_);
    if (fileExists(default_file_)) {
        try {
            file_strm_1 >> cached_settings_;
        } catch (json::parse_error) {
            LOG(warning) << "Default settings file is probably empty or corrupted.";
            return;
        }
    }
    std::ifstream file_strm_2(override_file_);
    if (fileExists(override_file_)) {
        try {
            file_strm_2 >> override_settings_;
        } catch (json::parse_error) {
            LOG(warning) << "Override settings file is probably empty or corrupted.";
        }
    }
    mergeSettings();
}


json_pointer UISettings::keyToJsonPointer(std::string key) {
    // change key to a JSON Pointer
    std::string dot = ".";
    std::string slash = "/";
    // taken from replace_subtring in nlohmann::json::json_pointer
    assert(not dot.empty());
    for (auto pos = key.find(dot);                 // find first occurrence of dot
         pos != std::string::npos;                 // make sure dot was found
         key.replace(pos, dot.size(), slash),      // replace with slash, and
         pos = key.find(dot, pos + slash.size()))  // find next occurrence of dot
    {}
    key = "/" + key;
    return json_pointer(key);
}

QString UISettings::getStrValue(const std::string &key) {
    return QString::fromStdString(cached_settings_.at(keyToJsonPointer(key)));
}

int UISettings::getIntValue(const std::string &key) {
    return cached_settings_.at(keyToJsonPointer(key));
}

bool UISettings::getBoolValue(const std::string &key) {
    return cached_settings_.at(keyToJsonPointer(key));
}

float UISettings::getFloatValue(const std::string &key) {
    return cached_settings_.at(keyToJsonPointer(key));
}

bool UISettings::fileExists(std::string file_name) {
    struct stat buf;
    return stat(file_name.c_str(), &buf) == 0;
}

void UISettings::writeSettings() {
    std::ofstream file_strm(override_file_);
    if (file_strm) {
        file_strm << std::setw(4) << cached_settings_;
    }
}

void UISettings::mergeSettings() {
    if (!override_settings_.is_null()) {
        cached_settings_.update(override_settings_);
    }
}
