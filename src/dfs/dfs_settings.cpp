#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include "dfs_settings.h"

DFSSettings::DFSSettings() :
    dfs_settings_path_(DFS_SETTINGS_PATH) {
    mkdir("/var/dfs", S_IFDIR);
    std::ifstream dfs_str(dfs_settings_path_);
    Json::Reader reader;
    if (!dfs_str || !reader.parse(dfs_str, dfs_setting_)) {
        dfs_setting_ = Json::Value();
    }
}

void DFSSettings::loadDFSSetting() {
    if (!dfs_setting_.isMember("region")) {
        dfs_setting_["region"] = Json::Value();
        DFSRegionSet(DFS::Global);
        updateDFSSetting(DFS::Global);
    } else {
        Json::Value &region = dfs_setting_["region"];
        if (region.isString()) {
            const QString code = region.asString().c_str();
            if (code == "00") {
                DFSRegionSet(DFS::Global);
            } else if (code == "KR") {
                DFSRegionSet(DFS::Korea);
            } else {
                DFSRegionSet(DFS::Global);
            }
        }
    }
}


void DFSSettings::updateDFSSetting(DFS region) {
    Json::Value &dfs_region = dfs_setting_["region"];

    dfs_region = Json::Value(dfs_region_str_[region]);

    std::string tmp_path = dfs_settings_path_ + ".tmp";
    std::ofstream tmp_str(tmp_path);
    tmp_str << dfs_setting_.toStyledString();

    // Hack to sync to disk since ofstream lacks flush() &
    // also there's no way to get the file descriptor from it.
    tmp_str.close();  // Force flush to filesystem buffer
    int fd = open(tmp_path.c_str(), O_APPEND);
    fsync(fd);
    if (fd) {
        rename(tmp_path.c_str(), dfs_settings_path_.c_str());
    }
    close(fd);
}
