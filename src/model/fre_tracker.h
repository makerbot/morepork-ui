// Copyright 2017 Makerbot Industries

#ifndef _SRC_FRE_TRACKER_H
#define _SRC_FRE_TRACKER_H
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/reader.h>
#include <QObject>

#include "base_model.h"

#define FRE_TRACKER_PATH std::string("/var/fre/fre_tracker.json")
#define FIRST_BOOT_FILE_PATH std::string("/home/.first_firmware_boot")

// First Run Experience Tracker
class FreTracker : public BaseModel {
  public:
    // MOREPORK_QML_ENUM
    enum FreStep {
        Welcome,
        SetupWifi,
        SoftwareUpdate,
        NamePrinter,
        LoginMbAccount,
        AttachExtruders,
        LoadMaterial,
        TestPrint,
        SetupComplete,
        FreComplete
    };

    Q_ENUM(FreStep)

    Q_INVOKABLE void gotoNextStep(uint current_step);
    Q_INVOKABLE void setFreStep(uint step);
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void acknowledgeFirstBoot();
    void logFreStatus();
    explicit FreTracker();

  private:
    Q_OBJECT

    Json::Value fre_status_;
    const std::string fre_tracker_path_;
    const std::string first_boot_path_;
    const std::vector<std::string> step_str_ =
    {
        "welcome",
        "setup_wifi",
        "software_update",
        "name_prnter",
        "login_mb_account",
        "attach_extruders",
        "load_material",
        "test_print",
        "setup_complete",
        "fre_complete"
    };
    std::string next_step_;
    MODEL_PROP(FreStep, currentFreStep, FreStep::Welcome)
    MODEL_PROP(bool, isFirstBoot, false)
};

#endif  // _SRC_FRE_TRACKER_H
