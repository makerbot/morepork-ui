#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include "fre_tracker.h"

FreTracker::FreTracker() :
    fre_tracker_path_(FRE_TRACKER_PATH),
    first_boot_path_(FIRST_BOOT_FILE_PATH) {
    mkdir("/var/fre", S_IFDIR);
    std::ifstream fre_str(fre_tracker_path_);
    Json::Reader reader;
    if (!fre_str || !reader.parse(fre_str, fre_status_)) {
        fre_status_ = Json::Value();
    }
    if (FILE *first_boot_file = fopen(first_boot_path_.c_str(), "r")) {
        fclose(first_boot_file);
        isFirstBootSet(true);
    } else {
        isFirstBootSet(false);
    }
}

void FreTracker::initialize() {
    if (!fre_status_.isMember("fre_status")) {
        currentFreStepSet(FreStep::Welcome);
        fre_status_["fre_status"] = Json::Value();
        Json::Value &fre_status = fre_status_["fre_status"];
        if (!fre_status.isMember("fre_complete")) {
            fre_status["fre_complete"] = Json::Value(false);
        }
        if (!fre_status.isMember("current_step")) {
            next_step_ = "welcome";
            fre_status["current_step"] = Json::Value(next_step_);
        }
        logFreStatus();
    } else {
        Json::Value &fre_status = fre_status_["fre_status"];
        if (fre_status.isMember("fre_complete")) {
            if (fre_status["fre_complete"].asBool()) {
                currentFreStepSet(FreStep::FreComplete);
            }
        }
        if (fre_status.isMember("current_step")) {
            const Json::Value kCurrentStep = fre_status["current_step"];
            if (kCurrentStep.isString()) {
                const QString step = kCurrentStep.asString().c_str();
                if (step == "welcome") {
                    currentFreStepSet(FreStep::Welcome);
                } else if (step == "setup_wifi") {
                    currentFreStepSet(FreStep::SetupWifi);
                } else if (step == "software_update") {
                    currentFreStepSet(FreStep::SoftwareUpdate);
                } else if (step == "name_printer") {
                    currentFreStepSet(FreStep::NamePrinter);
                } else if (step == "set_time_date") {
                    currentFreStepSet(FreStep::SetTimeDate);
                } else if (step == "login_mb_account") {
                    currentFreStepSet(FreStep::LoginMbAccount);
                } else if (step == "attach_extruders") {
                    currentFreStepSet(FreStep::AttachExtruders);
                } else if (step == "level_build_plate") {
                    currentFreStepSet(FreStep::LevelBuildPlate);
                } else if (step == "calibrate_extruders") {
                    currentFreStepSet(FreStep::CalibrateExtruders);
                } else if (step == "load_material") {
                    currentFreStepSet(FreStep::LoadMaterial);
                } else if (step == "test_print") {
                    currentFreStepSet(FreStep::TestPrint);
                } else if (step == "setup_complete") {
                    currentFreStepSet(FreStep::SetupComplete);
                } else if (step == "fre_complete") {
                    currentFreStepSet(FreStep::FreComplete);
                }
            }
        }
    }
}

void FreTracker::gotoNextStep(uint current_step) {
    currentFreStepSet(static_cast<FreStep>(++current_step));
    next_step_ = step_str_[current_step];
    logFreStatus();
}

void FreTracker::setFreStep(uint step) {
    currentFreStepSet(static_cast<FreStep>(step));
    next_step_ = step_str_[step];
    logFreStatus();
}

void FreTracker::logFreStatus() {
    Json::Value &fre_status = fre_status_["fre_status"];
    Json::Value &fre_complete = fre_status["fre_complete"];
    Json::Value &current_step = fre_status["current_step"];

    if (next_step_ == "fre_complete") {
        fre_complete = Json::Value(true);
    } else {
        fre_complete = Json::Value(false);
    }

    current_step = Json::Value(next_step_);

    std::string tmp_path = fre_tracker_path_ + ".tmp";
    std::ofstream tmp_str(tmp_path);
    tmp_str << fre_status_.toStyledString();

    // Hack to sync to disk since ofstream lacks flush() &
    // also there's no way to get the file descriptor from it.
    tmp_str.close();  // Force flush to filesystem buffer
    int fd = open(tmp_path.c_str(), O_APPEND);
    fsync(fd);
    if (fd) {
        rename(tmp_path.c_str(), fre_tracker_path_.c_str());
    }
    close(fd);
}

void FreTracker::acknowledgeFirstBoot() {
// TODO(praveen): Check if the first boot file is used
// elsewhere before deleting it
    remove(first_boot_path_.c_str());
    isFirstBootSet(false);
}
