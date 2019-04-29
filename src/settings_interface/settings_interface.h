// Copyright 2019 MakerBot Industries.

#ifndef SETTINGS_INTERFACE_H_
#define SETTINGS_INTERFACE_H_

#include <QObject>
#include <string>
#include "ui_settings.h"

class SettingsInterface : public QObject {
  Q_OBJECT
  public:
      SettingsInterface();
      /* When adding a new key and value into the settings file,
       * we want to create a get and set functions for it.
       * If the new key is nested inside another json object,
       * for example, { "key1": {"key2": "value"}},
       * then we use a key1.key2 notation when using the
       * UISettings::getValue, setValue functions.
       */
      Q_INVOKABLE QString getLanguageCode();
      Q_INVOKABLE bool getAllowInternalStorage();
      Q_INVOKABLE void setLanguageCode(const std::string language_code);
      Q_INVOKABLE void setAllowInternalStorage(bool allow);
  private:
      UISettings *ui_settings_;
};

#endif /* SETTINGS_INTERFACE_H_ */
