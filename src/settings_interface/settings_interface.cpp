// Copyright 2019 MakerBot Industries.

#include <sys/stat.h>
#include <fstream>  // NOLINT(readability/streams)
#include "settings_interface.h"

SettingsInterface::SettingsInterface() 
    : ui_settings_(new UISettings("/usr/settings/ui_settings.json",
                                  "/home/settings/ui_settings.json")) {
}

QString SettingsInterface::getLanguageCode() {
    return ui_settings_->getStrValue("language_code");
}

void SettingsInterface::setLanguageCode(const std::string language_code) {
    ui_settings_->setValue("language_code", language_code);
}

bool SettingsInterface::getAllowInternalStorage() {
    return ui_settings_->getBoolValue("allow_internal_storage");
}

void SettingsInterface::setAllowInternalStorage(bool allow) {
    ui_settings_->setValue("allow_internal_storage", allow);
}

/*
// In settings file:
// { "foo":
//     { "bar": "my_value"}
// }
QString SettingsInterface::getBar() {
    return ui_settings_->getStrValue("foo.bar");
}

void SettingsInterface::setBar(const std::string bar) {
    ui_settings_->setValue("foo.bar", language_code);
}
*/
