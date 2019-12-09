// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_MODEL_H
#define _SRC_BOT_MODEL_H

#include <QObject>
#include <QList>
#include <QDebug>

#include "base_model.h"
#include "net_model.h"
#include "process_model.h"


// The top level API for our bot model.  We don't allow direct instantiation
// because this doesn't initialize submodels.
class BotModel : public BaseModel {
  public:
    // MOREPORK_QML_ENUM
    enum MachineType {
        Fire,
        Lava
    };

    // MOREPORK_QML_ENUM
    enum ExtruderType {
        NONE,
        MK14,
        MK14_HOT,
        MK14_EXP
    };

    // MOREPORK_QML_ENUM
    enum ConnectionState {
        Connecting,
        Connected,
        Disconnected,
        TimedOut
    };

    Q_ENUM(MachineType)
    Q_ENUM(ExtruderType)
    Q_ENUM(ConnectionState)

    Q_INVOKABLE virtual void cancel();
    Q_INVOKABLE virtual void pauseResumePrint(QString action);
    Q_INVOKABLE virtual void print(QString file_name);
    Q_INVOKABLE virtual void done(QString acknowledge_result);
    Q_INVOKABLE virtual void loadFilament(const int kToolIndex, bool external, bool whilePrinting, QList<int> temperature = {0,0});
    Q_INVOKABLE virtual void loadFilamentStop();
    Q_INVOKABLE virtual void unloadFilament(const int kToolIndex, bool external, bool whilePrinting, QList<int> temperature = {0,0});
    Q_INVOKABLE virtual void assistedLevel();
    Q_INVOKABLE virtual void acknowledge_level();
    Q_INVOKABLE virtual void continue_leveling();
    Q_INVOKABLE virtual void respondAuthRequest(QString response);
    Q_INVOKABLE virtual void respondInstallUnsignedFwRequest(QString response);
    Q_INVOKABLE virtual void firmwareUpdateCheck(bool dont_force_check);
    Q_INVOKABLE virtual void installFirmware();
    Q_INVOKABLE virtual void installFirmwareFromPath(const QString file_path);
    Q_INVOKABLE virtual void calibrateToolheads(QList<QString> axes);
    Q_INVOKABLE virtual void doNozzleCleaning(bool clean);
    Q_INVOKABLE virtual void acknowledgeNozzleCleaned();
    Q_INVOKABLE virtual void buildPlateState(bool state);
    Q_INVOKABLE virtual void query_status();
    Q_INVOKABLE virtual void resetToFactory(bool clearCalibration);
    Q_INVOKABLE virtual void buildPlateCleared();
    Q_INVOKABLE virtual void scanWifi(bool force_rescan);
    Q_INVOKABLE virtual void toggleWifi(bool enable);
    Q_INVOKABLE virtual void disconnectWifi(QString path);
    Q_INVOKABLE virtual void connectWifi(QString path, QString password, QString name);
    Q_INVOKABLE virtual void forgetWifi(QString path);
    Q_INVOKABLE virtual void addMakerbotAccount(QString username, QString makerbot_token);
    Q_INVOKABLE virtual void zipLogs(QString path);
    Q_INVOKABLE virtual void forceSyncFile(QString path);
    Q_INVOKABLE virtual void changeMachineName(QString new_name);
    Q_INVOKABLE virtual void acknowledgeMaterial(bool response);
    Q_INVOKABLE virtual void acknowledgeSafeToRemoveUsb();
    Q_INVOKABLE virtual void getSystemTime();
    Q_INVOKABLE virtual void setSystemTime(QString new_time);
    Q_INVOKABLE virtual void deauthorizeAllAccounts();
    Q_INVOKABLE virtual void preheatChamber(const int chamber_temperature);
    Q_INVOKABLE virtual void moveAxis(QString axis, float distance, float speed);
    Q_INVOKABLE virtual void moveAxisToEndstop(QString axis, float distance, float speed);
    Q_INVOKABLE virtual void resetSpoolProperties(const int bay_index);
    Q_INVOKABLE virtual void shutdown();
    Q_INVOKABLE virtual void getToolStats(const int index);
    Q_INVOKABLE virtual void setTimeZone(const QString time_zone);
    Q_INVOKABLE virtual void getCloudServicesInfo();
    Q_INVOKABLE virtual void setAnalyticsEnabled(const bool enabled);
    Q_INVOKABLE virtual void drySpool();
    Q_INVOKABLE virtual void startDrying(const int temperature, const float time);
    Q_INVOKABLE virtual void get_calibration_offsets();
    Q_INVOKABLE virtual void cleanNozzles(const QList<int> temperature = {0,0});
    QStringList firmwareReleaseNotesList();
    void firmwareReleaseNotesListSet(QStringList &releaseNotesList);
    void firmwareReleaseNotesListReset();

  private:
    Q_OBJECT
    SUBMODEL(NetModel, net)
    SUBMODEL(ProcessModel, process)
    MODEL_PROP(MachineType, machineType, Fire)
    MODEL_PROP(QString, name, "Unknown")
    MODEL_PROP(QString, version, "Unknown")
    MODEL_PROP(bool, firmwareUpdateAvailable, false)
    MODEL_PROP(QString, firmwareUpdateVersion, "Unknown")
    MODEL_PROP(QString, firmwareUpdateReleaseDate, "Unknown")
    MODEL_PROP(QString, firmwareUpdateReleaseNotes, "Unknown")
    QStringList m_firmwareReleaseNotes;
    Q_PROPERTY(QStringList firmwareReleaseNotesList
               READ firmwareReleaseNotesList
               WRITE firmwareReleaseNotesListSet
               RESET firmwareReleaseNotesListReset
               NOTIFY firmwareReleaseNotesListChanged)
    MODEL_PROP(ConnectionState, state, Connecting)
    MODEL_PROP(QString, username, "Unknown")
    MODEL_PROP(QString, systemTime, "Unknown")
    MODEL_PROP(QString, timeZone, "Unknown")
    MODEL_PROP(bool, isAuthRequestPending, false)
    MODEL_PROP(bool, isInstallUnsignedFwRequestPending, false)
    // TODO(praveen): Would be good to move these extruder
    //                properties to it's own sub model.
    MODEL_PROP(ExtruderType, extruderAType, NONE)
    MODEL_PROP(ExtruderType, extruderBType, NONE)
    MODEL_PROP(bool, updatingExtruderFirmware, false)
    MODEL_PROP(int, extruderFirmwareUpdateProgressA, 0)
    MODEL_PROP(int, extruderFirmwareUpdateProgressB, 0)
    MODEL_PROP(int, extruderACurrentTemp, -999)
    MODEL_PROP(int, extruderATargetTemp, -999)
    MODEL_PROP(bool, extruderAToolTypeCorrect, false)
    MODEL_PROP(bool, extruderAPresent, false)
    MODEL_PROP(bool, extruderAFilamentPresent, false)
    MODEL_PROP(QString, extruderAErrorCode, 0)
    MODEL_PROP(bool, extruderAToolheadDisconnect, false)
    MODEL_PROP(bool, extruderACalibrated, true)
    MODEL_PROP(int, extruderBCurrentTemp, -999)
    MODEL_PROP(int, extruderBTargetTemp, -999)
    MODEL_PROP(bool, extruderBToolTypeCorrect, false)
    MODEL_PROP(bool, extruderBPresent, false)
    MODEL_PROP(bool, extruderBFilamentPresent, false)
    MODEL_PROP(QString, extruderBErrorCode, 0)
    MODEL_PROP(bool, extruderBToolheadDisconnect, false)
    MODEL_PROP(bool, extruderBCalibrated, true)
    MODEL_PROP(bool, extrudersCalibrated, true)
    MODEL_PROP(int, chamberCurrentTemp, -999)
    MODEL_PROP(int, chamberTargetTemp, -999)
    MODEL_PROP(int, chamberErrorCode, 0)
    MODEL_PROP(int, filamentBayATemp, -999)
    MODEL_PROP(int, filamentBayBTemp, -999)
    MODEL_PROP(int, filamentBayAHumidity, -999)
    MODEL_PROP(int, filamentBayBHumidity, -999)
    MODEL_PROP(bool, filamentBayAFilamentPresent, false)
    MODEL_PROP(bool, filamentBayBFilamentPresent, false)
    MODEL_PROP(bool, filamentBayATagPresent, false)
    MODEL_PROP(bool, filamentBayBTagPresent, false)
    MODEL_PROP(QString, filamentBayATagUID, "Unknown")
    MODEL_PROP(QString, filamentBayBTagUID, "Unknown")
    MODEL_PROP(bool, filamentBayATagVerified, false)
    MODEL_PROP(bool, filamentBayBTagVerified, false)
    MODEL_PROP(bool, filamentBayATagVerificationDone, false)
    MODEL_PROP(bool, filamentBayBTagVerificationDone, false)
    MODEL_PROP(int, filament1Percent, 0)
    MODEL_PROP(int, filament2Percent, 0)
    MODEL_PROP(bool, topLoadingWarning, false)
    MODEL_PROP(bool, spoolValidityCheckPending, false)
    MODEL_PROP(QString, unknownMaterialWarningType, "None")
    MODEL_PROP(bool, safeToRemoveUsb, false)
    MODEL_PROP(bool, doorLidErrorDisabled, false)

    MODEL_PROP(int, spoolAOriginalAmount, 0)
    MODEL_PROP(int, spoolBOriginalAmount, 0)
    MODEL_PROP(int, spoolAVersion, 0)
    MODEL_PROP(int, spoolBVersion, 0)
    MODEL_PROP(int, spoolAManufacturingLotCode, 0)
    MODEL_PROP(int, spoolBManufacturingLotCode, 0)
    MODEL_PROP(QString, spoolASupplierCode, "Unknown")
    MODEL_PROP(QString, spoolBSupplierCode, "Unknown")
    MODEL_PROP(QList<int>, spoolAColorRGB, QList<int>({0,0,0}))
    MODEL_PROP(QList<int>, spoolBColorRGB, QList<int>({0,0,0}))
    // TODO(shirley): (duplicate with filament1/2Color)
    MODEL_PROP(QString, spoolAColorName, "Reading Spool...")
    MODEL_PROP(QString, spoolBColorName, "Reading Spool...")

    // TODO(shirley) Should probably convert to string when mapping of codes to
    // filament type names is available
    MODEL_PROP(int, spoolAMaterial, 0)
    MODEL_PROP(int, spoolBMaterial, 0)
    MODEL_PROP(int, spoolAManufacturingDate, 0)
    MODEL_PROP(int, spoolBManufacturingDate, 0)
    MODEL_PROP(int, spoolAChecksum, 0)
    MODEL_PROP(int, spoolBChecksum, 0)

    MODEL_PROP(int, spoolAAmountRemaining, 0)
    MODEL_PROP(int, spoolBAmountRemaining, 0)
    MODEL_PROP(int, spoolAFirstLoadDate, 0)
    MODEL_PROP(int, spoolBFirstLoadDate, 0)
    MODEL_PROP(int, spoolAMaxHumidity, 0)
    MODEL_PROP(int, spoolBMaxHumidity, 0)
    MODEL_PROP(int, spoolAMaxTemperature, 0)
    MODEL_PROP(int, spoolBMaxTemperature, 0)
    MODEL_PROP(int, spoolASchemaVersion, 0)
    MODEL_PROP(int, spoolBSchemaVersion, 0)

    MODEL_PROP(bool, spoolADetailsReady, false)
    MODEL_PROP(bool, spoolBDetailsReady, false)

    MODEL_PROP(bool, spoolAUpdateFinished, true)
    MODEL_PROP(bool, spoolBUpdateFinished, true)

    MODEL_PROP(float, spoolALinearDensity, -999.999)
    MODEL_PROP(float, spoolBLinearDensity, -999.999)

    // Advanced Info Properties
    // Chamber
    MODEL_PROP(int, infoChamberCurrentTemp, -999)
    MODEL_PROP(int, infoChamberTargetTemp, -999)
    MODEL_PROP(int, infoChamberFanASpeed, -999)
    MODEL_PROP(int, infoChamberFanBSpeed, -999)
    MODEL_PROP(int, infoChamberHeaterATemp, -999)
    MODEL_PROP(int, infoChamberHeaterBTemp, -999)
    MODEL_PROP(int, infoChamberError, -0)
    // Filament Bay
    // Bay 1
    MODEL_PROP(int, infoBay1Temp, -999)
    MODEL_PROP(int, infoBay1Humidity, -999)
    MODEL_PROP(bool, infoBay1FilamentPresent, false)
    MODEL_PROP(bool, infoBay1TagPresent, -999)
    MODEL_PROP(QString, infoBay1TagUID, "Unknown")
    MODEL_PROP(bool, infoBay1TagVerified, false)
    MODEL_PROP(bool, infoBay1VerificationDone, false)
    MODEL_PROP(int, infoBay1Error, -999)
    // Bay 2
    MODEL_PROP(int, infoBay2Temp, -999)
    MODEL_PROP(int, infoBay2Humidity, -999)
    MODEL_PROP(bool, infoBay2FilamentPresent, false)
    MODEL_PROP(bool, infoBay2TagPresent, -999)
    MODEL_PROP(QString, infoBay2TagUID, "Unknown")
    MODEL_PROP(bool, infoBay2TagVerified, false)
    MODEL_PROP(bool, infoBay2VerificationDone, false)
    MODEL_PROP(int, infoBay2Error, -999)
    // Motion Status
    // Axis Enabled
    MODEL_PROP(bool, infoAxisXEnabled, false)
    MODEL_PROP(bool, infoAxisYEnabled, false)
    MODEL_PROP(bool, infoAxisZEnabled, false)
    MODEL_PROP(bool, infoAxisAEnabled, false)
    MODEL_PROP(bool, infoAxisBEnabled, false)
    MODEL_PROP(bool, infoAxisAAEnabled, false)
    MODEL_PROP(bool, infoAxisBBEnabled, false)
    // Endstop Activated
    MODEL_PROP(bool, infoAxisXEndStopActive, false)
    MODEL_PROP(bool, infoAxisYEndStopActive, false)
    MODEL_PROP(bool, infoAxisZEndStopActive, false)
    MODEL_PROP(bool, infoAxisAEndStopActive, false)
    MODEL_PROP(bool, infoAxisBEndStopActive, false)
    MODEL_PROP(bool, infoAxisAAEndStopActive, false)
    MODEL_PROP(bool, infoAxisBBEndStopActive, false)
    // Position
    MODEL_PROP(float, infoAxisXPosition, -999.999)
    MODEL_PROP(float, infoAxisYPosition, -999.999)
    MODEL_PROP(float, infoAxisZPosition, -999.999)
    MODEL_PROP(float, infoAxisAPosition, -999.999)
    MODEL_PROP(float, infoAxisBPosition, -999.999)
    MODEL_PROP(float, infoAxisAAPosition, -999.999)
    MODEL_PROP(float, infoAxisBBPosition, -999.999)
    // Toolheads
    // Toolhead A/1
    MODEL_PROP(bool, infoToolheadAAttached, false)
    MODEL_PROP(bool, infoToolheadAFilamentPresent, false)
    MODEL_PROP(bool, infoToolheadAFilamentJamEnabled, false)
    MODEL_PROP(int, infoToolheadACurrentTemp, -999)
    MODEL_PROP(int, infoToolheadATargetTemp, -999)
    MODEL_PROP(int, infoToolheadAEncoderTicks, -999)
    MODEL_PROP(int, infoToolheadAActiveFanRPM, -999)
    MODEL_PROP(int, infoToolheadAGradientFanRPM, -999)
    MODEL_PROP(float, infoToolheadAHESValue, -999.999)
    MODEL_PROP(QString, infoToolheadAError, "0")

    // Toolhead B/2
    MODEL_PROP(bool, infoToolheadBAttached, false)
    MODEL_PROP(bool, infoToolheadBFilamentPresent, false)
    MODEL_PROP(bool, infoToolheadBFilamentJamEnabled, false)
    MODEL_PROP(int, infoToolheadBCurrentTemp, -999)
    MODEL_PROP(int, infoToolheadBTargetTemp, -999)
    MODEL_PROP(int, infoToolheadBEncoderTicks, -999)
    MODEL_PROP(int, infoToolheadBActiveFanRPM, -999)
    MODEL_PROP(int, infoToolheadBGradientFanRPM, -999)
    MODEL_PROP(float, infoToolheadBHESValue, -999.999)
    MODEL_PROP(QString, infoToolheadBError, "0")

    // Extruder A Stats
    MODEL_PROP(int, extruderAShortRetractCount, 0)
    MODEL_PROP(int, extruderALongRetractCount, 0)
    MODEL_PROP(int, extruderAExtrusionDistance, 0)

    // Extruder B Stats
    MODEL_PROP(int, extruderBShortRetractCount, 0)
    MODEL_PROP(int, extruderBLongRetractCount, 0)
    MODEL_PROP(int, extruderBExtrusionDistance, 0)

    // Misc.
    MODEL_PROP(bool, infoDoorActivated, false)
    MODEL_PROP(bool, infoLidActivated, false)
    MODEL_PROP(int, infoTopBunkFanARPM, -999)
    MODEL_PROP(int, infoTopBunkFanBRPM, -999)
    MODEL_PROP(QString, cameraState, "Unknown")

    // Calibration Offsets
    MODEL_PROP(float, offsetAX, -999.999)
    MODEL_PROP(float, offsetAY, -999.999)
    MODEL_PROP(float, offsetAZ, -999.999)
    MODEL_PROP(float, offsetBX, -999.999)
    MODEL_PROP(float, offsetBY, -999.999)
    MODEL_PROP(float, offsetBZ, -999.999)

  protected:
    BotModel();

  signals:
    void firmwareReleaseNotesListChanged();

};

// Make a dummy implementation of the API with all submodels filled in.
BotModel * makeBotModel();

#endif  // _SRC_BOT_MODEL_H
