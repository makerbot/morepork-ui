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
}

void DFSSettings::loadDFSSetting() {
    std::ifstream dfs_str(dfs_settings_path_);
    if(!dfs_str.is_open()) return;
    std::string code;
    std::getline(dfs_str, code);
    dfs_str.close();
    if (code == "00") {
        DFSRegionSet(DFS::Global);
    } else if (code == "KR") {
        DFSRegionSet(DFS::Korea);
    } else {
        DFSRegionSet(DFS::Global);
    }
}

void DFSSettings::updateDFSSetting(DFS region) {
    std::string code = dfs_region_str_[region];
    std::string tmp_path = dfs_settings_path_ + ".tmp";
    std::ofstream tmp_str(tmp_path, std::ofstream::out);
    tmp_str << code;
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
