// Copyright 2019 MakerBot Industries.

#include <sys/stat.h>
#include <fstream>  // NOLINT(readability/streams)
#include "settings_interface.h"

SettingsInterface::SettingsInterface() 
    : default_file_(DEFAULT_UI_SETTINGS_PATH),
      override_file_(OVERRIDE_UI_SETTINGS_PATH) {
    initialize();
}

void SettingsInterface::initialize() {
    if (!fileExists(default_file_)) {
        LOG(error) << "Default settings file does not exist.";
        return;
    }
    std::ifstream file_strm_1(default_file_);
    Json::Reader reader;
    // Make sure there is content in the file and json parsing is successful
    if (!(file_strm_1 && reader.parse(file_strm_1, cached_settings_))) {
        LOG(error) << "Default settings file parse error";
    }
    std::ifstream file_strm_2(override_file_);
    Json::Value override_settings;
    if (!(file_strm_2 && reader.parse(file_strm_2, override_settings))) {
        LOG(error) << "Override settings file parse error";
    }
    mergeSettings(cached_settings_, override_settings);
}

bool SettingsInterface::fileExists(std::string file_name) {
    struct stat buf;
    return stat(file_name.c_str(), &buf) == 0;
}

void SettingsInterface::writeSettings() {
    std::ofstream file_strm(override_file_);
    if (file_strm) {
        Json::StyledWriter styledWriter;
        file_strm << styledWriter.write(cached_settings_);
    }
}

void SettingsInterface::mergeSettings(Json::Value &s1, Json::Value s2) {
    if (!s1.isObject() || !s2.isObject()) return;
    for (const auto& key : s2.getMemberNames()) {
        if (s1[key].isObject()) {
            mergeSettings(s1[key], s2[key]);
        } else {
            s1[key] = s2[key];
        }
    }
}

QString SettingsInterface::getLanguageCode() {
    return QString::fromStdString(cached_settings_["language_code"].asString());
}

void SettingsInterface::setLanguageCode(const std::string language_code) {
    cached_settings_["language_code"] = language_code;
    writeSettings();
}

bool SettingsInterface::getAllowInternalStorage() {
    return cached_settings_["allow_internal_storage"].asBool();
}

void SettingsInterface::setAllowInternalStorage(bool allow) {
    cached_settings_["allow_internal_storage"] = allow;
    writeSettings();
}
