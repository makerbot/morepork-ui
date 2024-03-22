// Copyright 2019 MakerBot Industries.

#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
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
    std::string tmp_path = override_file_ + ".tmp";
    std::ofstream tmp_strm(tmp_path);
    tmp_strm << cached_settings_.toStyledString();
    tmp_strm.close(); //force flush
    int fd = open(tmp_path.c_str(), O_APPEND);
    fsync(fd);
    if (fd) {
        int err = rename(tmp_path.c_str(), override_file_.c_str());
        if (err) {
            LOG(info) << "Error writing to settings "
                      << override_file_.c_str()
                      << ": "
                      << strerror(err);
        }
    }
    close(fd);
}

void SettingsInterface::mergeSettings(Json::Value &s1, Json::Value s2) {
    if (!s1.isObject() || !s2.isObject()) return;
    for (const auto& key : s2.getMemberNames()) {
        if (!s1.isMember(key)) continue;
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

void SettingsInterface::setLanguageCode(const QString language_code) {
    cached_settings_["language_code"] = language_code.toStdString();
    writeSettings();
}

bool SettingsInterface::getSkipFilamentNags() {
    return cached_settings_["skip_filament_nags"].asBool();
}

bool SettingsInterface::getAllowInternalStorage() {
    return cached_settings_["allow_internal_storage"].asBool();
}

void SettingsInterface::setAllowInternalStorage(bool allow) {
    cached_settings_["allow_internal_storage"] = allow;
    writeSettings();
}

bool SettingsInterface::getShowNylonCFAnnealPrintTip() {
    return cached_settings_["show_nylon_cf_anneal_print_tip"].asBool();
}

void SettingsInterface::setShowNylonCFAnnealPrintTip(bool show) {
    cached_settings_["show_nylon_cf_anneal_print_tip"] = show;
    writeSettings();
}

void SettingsInterface::setShowApplyGlueOnBuildPlateTip(QString material, bool show) {
    cached_settings_["show_apply_glue_on_build_plate_tip"][material.toStdString()] = show;
    writeSettings();
}

bool SettingsInterface::getShowApplyGlueOnBuildPlateTip(QString material) {
    const Json::Value &val = cached_settings_["show_apply_glue_on_build_plate_tip"];
    return val.get(material.toStdString(), false).asBool();
}

bool SettingsInterface::getShowTimeInTopBar() {
    return cached_settings_["show_time_in_top_bar"].asBool();
}

void SettingsInterface::setShowTimeInTopBar(bool enable) {
    cached_settings_["show_time_in_top_bar"] = enable;
    writeSettings();
}

bool SettingsInterface::getCaptureTimelapseImages() {
    return cached_settings_["capture_timelapse_images"].asBool();
}

void SettingsInterface::resetPreferences() {
    cached_settings_["show_nylon_cf_anneal_print_tip"] = true;
    Json::Value &val = cached_settings_["show_apply_glue_on_build_plate_tip"];
    for(const auto &key : val.getMemberNames()) {
        val[key] = true;
    }
    cached_settings_["show_time_in_top_bar"] = false;
    writeSettings();
}
