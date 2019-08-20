// Copyright 2019 Makerbot Industries

#ifndef _SRC_DFS_SETTINGS_H
#define _SRC_DFS_SETTINGS_H
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/reader.h>
#include <QObject>

#include "base_model.h"

#define DFS_SETTINGS_PATH ("/var/dfs/dfs_settings.json")

class DFSSettings : public BaseModel {
  public:
    // MOREPORK_QML_ENUM
    enum DFS {
        Global,
        Korea
    };
    Q_ENUM(DFS)

    Q_INVOKABLE void loadDFSSetting();
    Q_INVOKABLE void updateDFSSetting(DFS region);
    explicit DFSSettings();

  private:
    Q_OBJECT
    Json::Value dfs_setting_;
    std::string dfs_settings_path_;
    const std::vector<std::string> dfs_region_str_ =
    {
        "00", // Global code (default)
        "KR" // ISO 3166-1 alpha-2 code for South Korea
    };
    MODEL_PROP(DFS, DFSRegion, Global)
};

#endif  // _SRC_DFS_SETTINGS_H
