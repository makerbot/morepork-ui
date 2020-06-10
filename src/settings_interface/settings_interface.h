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

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
// desktop linux path
#define OVERRIDE_UI_SETTINGS_PATH "/home/"+qgetenv("USER")+"/settings/ui_settings.json"
#ifdef SETTINGS_FILE_DIR
#define DEFAULT_UI_SETTINGS_PATH SETTINGS_FILE_DIR+std::string("/ui_settings.json")
#else
#define DEFAULT_UI_SETTINGS_PATH "/home/"+qgetenv("USER")+"/settings/ui_settings.json"
#endif
#else
// embedded linux path
#define OVERRIDE_UI_SETTINGS_PATH "/home/settings/ui_settings.json"
#define DEFAULT_UI_SETTINGS_PATH "/usr/settings/ui_settings.json"
#endif

class SettingsInterface : public QObject {
  Q_OBJECT
  public:
      SettingsInterface();
      Q_INVOKABLE QString getLanguageCode();
      Q_INVOKABLE bool getAllowInternalStorage();
      Q_INVOKABLE bool getSkipFilamentNags();
      Q_INVOKABLE void setLanguageCode(const QString language_code);
      Q_INVOKABLE void setAllowInternalStorage(bool allow);
      Q_INVOKABLE bool getShowNylonCFAnnealPrintTip();
      Q_INVOKABLE void setShowNylonCFAnnealPrintTip(bool show);
      Q_INVOKABLE bool getShowApplyGlueOnBuildPlateTip(QString material);
      Q_INVOKABLE void setShowApplyGlueOnBuildPlateTip(QString material, bool show);
      Q_INVOKABLE void resetPreferences();
  private:
      std::string default_file_, override_file_;
      void initialize(void);
      bool fileExists(std::string file_name);
      void writeSettings();
      void mergeSettings(Json::Value &s1, Json::Value s2);
      Json::Value cached_settings_;
};

#endif /* SETTINGS_INTERFACE_H_ */
