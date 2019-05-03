// Copyright 2019 MakerBot Industries.

#ifndef SETTINGS_INTERFACE_H_
#define SETTINGS_INTERFACE_H_

#include <QDebug>
#include <QObject>
#include <string>
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/reader.h>
#include <jsoncpp/json/writer.h>

#include "logging.h"

class SettingsInterface : public QObject {
  Q_OBJECT
  public:
      SettingsInterface();
      Q_INVOKABLE QString getLanguageCode();
      Q_INVOKABLE bool getAllowInternalStorage();
      Q_INVOKABLE void setLanguageCode(const std::string language_code);
      Q_INVOKABLE void setAllowInternalStorage(bool allow);
  private:
      std::string default_file_, override_file_;
      void initialize(void);
      bool fileExists(std::string file_name);
      void writeSettings();
      void mergeSettings(Json::Value &s1, Json::Value s2);
      Json::Value cached_settings_;
};

#endif /* SETTINGS_INTERFACE_H_ */
