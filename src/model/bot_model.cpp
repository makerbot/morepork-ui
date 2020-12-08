// Copyright 2017 Makerbot Industries

#include "bot_model.h"
#include "error_utils.h"

BotModel::BotModel() {
    reset();
}

QStringList BotModel::firmwareReleaseNotesList() {
    return m_firmwareReleaseNotes;
}

void BotModel::firmwareReleaseNotesListSet(QStringList &release_notes) {
    auto temp = release_notes;
    m_firmwareReleaseNotes = release_notes;
    emit firmwareReleaseNotesListChanged();
    temp.clear();
}

void BotModel::firmwareReleaseNotesListReset() {
    m_firmwareReleaseNotes.clear();
}

void BotModel::cancel() {
    qDebug() << FL_STRM << "called";
}

void BotModel::pauseResumePrint(QString action) {
    qDebug() << FL_STRM << "called with action: " << action;
}

void BotModel::print(QString file_name) {
    qDebug() << FL_STRM << "called with file name: " << file_name;
}

void BotModel::done(QString acknowledge_result) {
    qDebug() << FL_STRM << "called with acknowledge_result: " << acknowledge_result;
}

void BotModel::loadFilament(const int kToolIndex, bool external, bool whilePrinting, QList<int> temperature) {
    qDebug() << FL_STRM << "called with tool_index: " << kToolIndex << " temperature: " << temperature[kToolIndex] << " external: " << external << " whilePrinting: " << whilePrinting;
}

void BotModel::loadFilamentStop() {
    qDebug() << FL_STRM << "called";
}

void BotModel::unloadFilament(const int kToolIndex, bool external, bool whilePrinting, QList<int> temperature) {
    qDebug() << FL_STRM << "called with tool_index: " << kToolIndex << " temperature: " << temperature[kToolIndex] << " external: " << external << " whilePrinting " << whilePrinting;
}

void BotModel::assistedLevel() {
    qDebug() << FL_STRM << "called";
}

void BotModel::continue_leveling() {
    qDebug() << FL_STRM << "called";
}

void BotModel::acknowledge_level() {
    qDebug() << FL_STRM << "called";
}

void BotModel::respondAuthRequest(QString response) {
    qDebug() << FL_STRM << "called with response: " << response;
}

void BotModel::respondInstallUnsignedFwRequest(QString response) {
    qDebug() << FL_STRM << "called with response: " << response;
}

void BotModel::firmwareUpdateCheck(bool dont_force_check) {
    qDebug() << FL_STRM << "called with parameter: " << dont_force_check;
}

void BotModel::installFirmware() {
    qDebug() << FL_STRM << "called";
}

void BotModel::installFirmwareFromPath(const QString file_path) {
    qDebug() << FL_STRM << "called with parameter: " << file_path;
}

void BotModel::calibrateToolheads(QList<QString> axes) {
    qDebug() << FL_STRM << "called";
    qDebug() << "Axes Requested:";
    for(int i = 0; i < axes.size(); i++) {
        qDebug() << axes.value(i);
    }
}

void BotModel::doNozzleCleaning(bool do_clean, QList<int> temperature) {
    qDebug() << FL_STRM << "called with parameter: " << do_clean;
    qDebug() << "Temperatures";
    for(int i = 0; i < temperature.size(); i++) {
        qDebug() << temperature.value(i);
    }
}

void BotModel::acknowledgeNozzleCleaned() {
    qDebug() << FL_STRM << "called";
}

void BotModel::buildPlateState(bool state) {
    qDebug() << FL_STRM << "called with parameter: " << state;
}

void BotModel::query_status() {
    qDebug() << FL_STRM << "called";
}

void BotModel::resetToFactory(bool clearCalibration) {
    qDebug() << FL_STRM << "called with parameter: " << clearCalibration;
}

void BotModel::buildPlateCleared() {
    qDebug() << FL_STRM << "called";
}

void BotModel::scanWifi(bool force_rescan) {
    qDebug() << FL_STRM << "called with parameter:" << force_rescan;
}

void BotModel::toggleWifi(bool enable) {
    qDebug() << FL_STRM << "called with parameter:" << enable;
}

void BotModel::disconnectWifi(QString path) {
    qDebug() << FL_STRM << "called with parameter:" << path;
}

void BotModel::connectWifi(QString path, QString password, QString name) {
    qDebug() << FL_STRM << "called with parameter:" << path << password << name;
}

void BotModel::forgetWifi(QString path) {
    qDebug() << FL_STRM << "called with parameter:" << path;
}

void BotModel::addMakerbotAccount(QString username, QString makerbot_token) {
    qDebug() << FL_STRM << "called with parameters:"
             << username << "; " <<  makerbot_token;
}

void BotModel::zipLogs(QString path) {
    qDebug() << FL_STRM << "called with parameter: " << path;
}

void BotModel::forceSyncFile(QString path) {
    qDebug() << FL_STRM << "called with parameter: " << path;
}

void BotModel::changeMachineName(QString new_name) {
    qDebug() << FL_STRM << "called with parameters: " << new_name;
}

void BotModel::acknowledgeMaterial(bool response) {
    qDebug() << FL_STRM << "called with parameters: " << response;
}

void BotModel::acknowledgeSafeToRemoveUsb() {
    qDebug() << FL_STRM << "called";
}

void BotModel::getSystemTime() {
    qDebug() << FL_STRM << "called";
}

void BotModel::setSystemTime(QString new_time) {
    qDebug() << FL_STRM << "called with parameters" << new_time;
}

void BotModel::deauthorizeAllAccounts() {
    qDebug() << FL_STRM << "called";
}

void BotModel::preheatChamber(int chamber_temperature) {
    qDebug() << FL_STRM << "called with parameters" << chamber_temperature;
}

void BotModel::moveAxis(QString axis, float distance, float speed) {
    qDebug() << FL_STRM << "called with parameters" << axis << distance << speed;
}

void BotModel::moveAxisToEndstop(QString axis, float distance, float speed) {
    qDebug() << FL_STRM << "called with parameters" << axis << distance << speed;
}

void BotModel::resetSpoolProperties(const int bay_index) {
    qDebug() << FL_STRM << "called with parameter" << bay_index;
}

void BotModel::shutdown() {
    qDebug() << FL_STRM << "called";
}

void BotModel::getToolStats(const int index) {
    qDebug() << FL_STRM << "called with parameter: " << index;
}

void BotModel::setTimeZone(const QString time_zone) {
    qDebug() << FL_STRM << "called with parameter: " << time_zone;
}

void BotModel::getCloudServicesInfo() {
    qDebug() << FL_STRM << "called";
}

void BotModel::setAnalyticsEnabled(const bool enabled) {
    qDebug() << FL_STRM << "called with parameter: " << enabled;
}

void BotModel::drySpool() {
    qDebug() << FL_STRM << "called";
}

void BotModel::startDrying(const int temperature, const float time) {
    qDebug() << FL_STRM << "called with parameters: " << temperature << " " << time;
}

void BotModel::get_calibration_offsets() {
    qDebug() << FL_STRM << "called";
}

void BotModel::cleanNozzles(const QList<int> temperature) {
    qDebug() << FL_STRM << "called";
    qDebug() << "Temperatures";
    for(int i = 0; i < temperature.size(); i++) {
        qDebug() << temperature.value(i);
    }
}

void BotModel::submitPrintFeedback(bool success, const QVariantMap failure_map) {
    qDebug() << FL_STRM << "called with parameters: " << success << " " << failure_map;
}

void BotModel::ignoreError(const int index, const QList<int> error, const bool ignored) {
    qDebug() << FL_STRM << "called with parameters " << index;
    for(auto e : error) {
        qDebug() << e;
    }
    qDebug() << ignored;
}

void BotModel::handshake() {
    qDebug() << FL_STRM << "called";
}

void BotModel::annealPrint() {
    qDebug() << FL_STRM << "called";
}

void BotModel::startAnnealing(const int temperature, const float time) {
    qDebug() << FL_STRM << "called with parameters: " << temperature << " " << time;
}

void BotModel::getAccessoriesStatus() {
    qDebug() << FL_STRM << "called";
}

class DummyBotModel : public BotModel {
  public:
    DummyBotModel() {
        m_net.reset(new NetModel());
        m_process.reset(new ProcessModel());
    }
};

BotModel * makeBotModel() {
    return dynamic_cast<BotModel *>(new DummyBotModel());
}
