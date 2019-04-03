// Copyright 2017 Makerbot Industries

#include "kaiten_bot_model.h"

#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

#include <memory>
#include <sstream>

#include <QJSEngine>

#include "impl_util.h"
#include "kaiten_net_model.h"
#include "kaiten_process_model.h"
#include "local_jsonrpc.h"
#include "error_utils.h"
#include "logging.h"

class KaitenBotModel : public BotModel {
  public:
    KaitenBotModel(const char * socketpath);
    void sysInfoUpdate(const Json::Value & info);
    void netUpdate(const Json::Value & info);
    void systemTimeUpdate(const Json::Value & time_update);
    void authRequestUpdate(const Json::Value &request);
    void installUnsignedFwRequestUpdate(const Json::Value &request);
    void firmwareUpdateNotif(const Json::Value & firmware_info);
    void printFileValidNotif(const Json::Value &info);
    void unknownMatWarningUpdate(const Json::Value &params);
    void usbCopyCompleteUpdate();
    void assistedLevelUpdate(const Json::Value & status);
    void queryStatusUpdate(const Json::Value & info);
    void wifiUpdate(const Json::Value & result);
    void cancel();
    void pauseResumePrint(QString action);
    void print(QString file_name);
    void done(QString acknowledge_result);
    void loadFilament(const int kToolIndex, bool external, bool whilePrinting);
    void loadFilamentStop();
    void unloadFilament(const int kToolIndex, bool external, bool whilePrinting);
    void assistedLevel();
    void continue_leveling();
    void acknowledge_level();
    std::shared_ptr<JsonRpcMethod::Response> m_authResp;
    std::shared_ptr<JsonRpcMethod::Response> m_installUnsignedFwResp;
    void respondAuthRequest(QString response);
    void respondInstallUnsignedFwRequest(QString response);
    void firmwareUpdateCheck(bool dont_force_check);
    void installFirmware();
    void installFirmwareFromPath(const QString file_path);
    void calibrateToolheads(QList<QString> axes);
    void doNozzleCleaning(bool do_clean);
    void acknowledgeNozzleCleaned();
    void buildPlateState(bool state);
    void query_status();
    void resetToFactory(bool clearCalibration);
    void buildPlateCleared();
    void toggleWifi(bool enable);
    void scanWifi(bool force_rescan);
    void connectWifi(QString path, QString password, QString name);
    void disconnectWifi(QString path);
    void forgetWifi(QString path);
    void addMakerbotAccount(QString username, QString makerbot_token);
    void getSpoolInfo(const int bayIndex);
    void updateSpoolInfo(const int bayIndex);
    void spoolUpdate(const Json::Value & res, const int bayIndex);
    void zipLogs(QString path);
    void forceSyncFile(QString path);
    void changeMachineName(QString new_name);
    void acknowledgeMaterial(bool response);
    void acknowledgeSafeToRemoveUsb();
    void getSystemTime();
    void setSystemTime(QString new_time);
    void deauthorizeAllAccounts();
    void preheatChamber(const int chamber_temperature);
    void moveAxis(QString axis, float distance, float speed);
    void resetSpoolProperties(const int bayID);
    void shutdown();
    bool checkError(const Json::Value error_list, const int error_code);
    void getToolStats(const int index);
    void toolStatsUpdate(const Json::Value & res, const int index);
    void setTimeZone(const QString time_zone);

    QScopedPointer<LocalJsonRpc, QScopedPointerDeleteLater> m_conn;
    void connected();
    void disconnected();
    void timeout();

    std::shared_ptr<JsonRpcMethod::Response> m_unsignedFwResp;

    class SystemNotification : public JsonRpcNotification {
      public:
        SystemNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->sysInfoUpdate(MakerBot::SafeJson::get_obj(params, "info"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<SystemNotification> m_sysNot;

    class SysInfoCallback : public JsonRpcCallback {
      public:
        SysInfoCallback(KaitenBotModel * bot) : m_bot(bot) {}
        void response(const Json::Value & resp) override {
            m_bot->sysInfoUpdate(MakerBot::SafeJson::get_obj(resp, "result"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<SysInfoCallback> m_sysInfoCb;

    class NetStateNotification : public JsonRpcNotification {
      public:
        NetStateNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->netUpdate(MakerBot::SafeJson::get_obj(params, "state"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<NetStateNotification> m_netNot;

    class NetStateCallback : public JsonRpcCallback {
      public:
        NetStateCallback(KaitenBotModel * bot) : m_bot(bot) {}
        void response(const Json::Value & resp) override {
            m_bot->netUpdate(MakerBot::SafeJson::get_obj(resp, "result"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<NetStateCallback> m_netStateCb;

    class AuthRequestMethod : public JsonRpcMethod {
      public:
        AuthRequestMethod(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params, std::shared_ptr<Response> response) {
            if(!m_bot->m_authResp) {
                m_bot->authRequestUpdate(params);
                m_bot->m_authResp = response;
            }
            else {
                Json::Value json_params(Json::objectValue);
                json_params["answer"] = Json::Value("rejected");
                response->sendResult(json_params);
            }
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<AuthRequestMethod> m_authReq;

    class FirmwareUpdateNotification : public JsonRpcNotification {
      public:
        FirmwareUpdateNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->firmwareUpdateNotif(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<FirmwareUpdateNotification> m_fwareUpNot;

    class AllowUnknownFirmware : public JsonRpcMethod {
      public:
        AllowUnknownFirmware(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params, std::shared_ptr<Response> response) {
            // If we don't have a popup in progress, show the popup
            if(!m_bot->m_installUnsignedFwResp) {
                m_bot->installUnsignedFwRequestUpdate(params);
                m_bot->m_installUnsignedFwResp = response;
            }
            // If we do have a popup in progress, don't show the popup
            else {
                Json::Value json_params(Json::objectValue);
                json_params = Json::Value("rejected");
                response->sendResult(json_params);
            }
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<AllowUnknownFirmware> m_allowUnkFw;

    class PrintFileUpdate : public JsonRpcNotification {
      public:
        PrintFileUpdate(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) {
            m_bot->printFileValidNotif(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<PrintFileUpdate> m_prtFileVld;

    class AssistedLevelNotification : public JsonRpcNotification {
      public:
        AssistedLevelNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->assistedLevelUpdate(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<AssistedLevelNotification> m_asstLvlNot;

    class AssistedLevelCallback : public JsonRpcCallback {
      public:
        AssistedLevelCallback(KaitenBotModel * bot) : m_bot(bot) {}
        void response(const Json::Value & resp) override {
            m_bot->assistedLevelUpdate(MakerBot::SafeJson::get_obj(resp, "result"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<AssistedLevelCallback> m_asstLvlCb;

    class QueryStatusNotification : public JsonRpcNotification {
      public:
        QueryStatusNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->queryStatusUpdate(MakerBot::SafeJson::get_obj(params, "result"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<QueryStatusNotification> m_queryStatusNot;

    class QueryStatusCallback : public JsonRpcCallback {
      public:
        QueryStatusCallback(KaitenBotModel * bot) : m_bot(bot) {}
        void response(const Json::Value & resp) override {
            m_bot->queryStatusUpdate(MakerBot::SafeJson::get_obj(resp, "result"));
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<QueryStatusCallback> m_queryStatusCb;

    class WifiUpdateResult : public JsonRpcNotification {
      public:
        WifiUpdateResult(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) override {
            m_bot->wifiUpdate(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<WifiUpdateResult> m_wifiResult;

    class WifiUpdateCallback : public JsonRpcCallback {
      public:
        WifiUpdateCallback(KaitenBotModel * bot) : m_bot(bot) {}
        void response(const Json::Value & resp) override {
            m_bot->wifiUpdate(resp);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<WifiUpdateCallback> m_wifiCb;

    class SpoolInfoCallback : public JsonRpcCallback {
      public:
        SpoolInfoCallback(KaitenBotModel * bot, const int bayIndex)
                : m_bot(bot),
                  m_index(bayIndex) {}
        void response(const Json::Value & resp) override {
            m_bot->spoolUpdate(resp, m_index);
        }
      private:
        const int m_index;
        KaitenBotModel *m_bot;
    };
    std::vector<std::shared_ptr<SpoolInfoCallback> > m_spoolInfoCb;

    class UpdateSpoolInfoCallback : public JsonRpcCallback {
      public:
        UpdateSpoolInfoCallback(KaitenBotModel * bot, const int bayIndex)
                : m_bot(bot),
                  m_index(bayIndex) {}
        void response(const Json::Value & resp) override {
            m_index ? m_bot->spoolBUpdateFinishedSet(true) :
                      m_bot->spoolAUpdateFinishedSet(true);
        }
      private:
        const int m_index;
        KaitenBotModel *m_bot;
    };
    std::vector<std::shared_ptr<UpdateSpoolInfoCallback> > m_updateSpoolInfoCb;

    class ToolStatsCallback : public JsonRpcCallback {
      public:
        ToolStatsCallback(KaitenBotModel * bot, const int index)
                : m_bot(bot),
                  m_index(index) {}
        void response(const Json::Value & resp) override {
            m_bot->toolStatsUpdate(resp, m_index);
        }
      private:
        const int m_index;
        KaitenBotModel *m_bot;
    };
    std::vector<std::shared_ptr<ToolStatsCallback> > m_toolStatsCb;

    class UnknownMaterialNotification : public JsonRpcNotification {
      public:
        UnknownMaterialNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) {
            m_bot->unknownMatWarningUpdate(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<UnknownMaterialNotification> m_matWarningNot;

    class UsbCopyCompleteNotification : public JsonRpcNotification {
      public:
        UsbCopyCompleteNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) {
            m_bot->usbCopyCompleteUpdate();
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<UsbCopyCompleteNotification> m_usbCopyCompleteNot;

    class SystemTimeNotification : public JsonRpcNotification {
      public:
        SystemTimeNotification(KaitenBotModel * bot) : m_bot(bot) {}
        void invoke(const Json::Value &params) {
            m_bot->systemTimeUpdate(params);
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<SystemTimeNotification> m_sysTimeNot;

    class SetTimeZoneCallback : public JsonRpcCallback {
      public:
        SetTimeZoneCallback() {}
        void response(const Json::Value & resp) override {
            // Just update the time zone directly here
            QJSEngine().evaluate("Date.timeZoneUpdated()");
        }
      private:
        KaitenBotModel *m_bot;
    };
    std::shared_ptr<SetTimeZoneCallback> m_stzCb;
};

void KaitenBotModel::authRequestUpdate(const Json::Value &request){
    isAuthRequestPendingSet(true);
    UPDATE_STRING_PROP(username, request["username"]);
}

void KaitenBotModel::installUnsignedFwRequestUpdate(const Json::Value &request){
    isInstallUnsignedFwRequestPendingSet(true);
}

void KaitenBotModel::respondAuthRequest(QString response){
    if(m_authResp) {
        Json::Value json_params(Json::objectValue);
        json_params["answer"] = Json::Value(response.toStdString());
        m_authResp->sendResult(json_params);
        m_authResp = nullptr;
        isAuthRequestPendingReset();
    }
}

void KaitenBotModel::respondInstallUnsignedFwRequest(QString response){
    if(m_installUnsignedFwResp) {
        Json::Value json_params(Json::objectValue);
        json_params = Json::Value(response.toStdString());
        m_installUnsignedFwResp->sendResult(json_params);
        m_installUnsignedFwResp = nullptr;
        isInstallUnsignedFwRequestPendingReset();
    }
}

void KaitenBotModel::unknownMatWarningUpdate(const Json::Value &request){
    UPDATE_STRING_PROP(unknownMaterialWarningType, request["type"]);
    const Json::Value &kWarningType = request["type"];
        if(kWarningType.isString()) {
            const QString kWarningTypeStr = kWarningType.asString().c_str();
            if(kWarningTypeStr == "top_loading") {
                topLoadingWarningSet(true);
            }
            else if(kWarningTypeStr == "assist_loading") {
                spoolValidityCheckPendingSet(true);
            }
        }
}

void KaitenBotModel::acknowledgeMaterial(bool response){
    topLoadingWarningReset();
    spoolValidityCheckPendingReset();
    if(response) {
        try{
            qDebug() << FL_STRM << "called";
            auto conn = m_conn.data();
            Json::Value json_params(Json::objectValue);
            json_params["method"] = Json::Value("acknowledge_material");
            conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
        }
        catch(JsonRpcInvalidOutputStream &e){
            qWarning() << FFL_STRM << e.what();
        }
    }
}

void KaitenBotModel::usbCopyCompleteUpdate(){
    safeToRemoveUsbSet(true);
}

void KaitenBotModel::acknowledgeSafeToRemoveUsb() {
    safeToRemoveUsbReset();
}

void KaitenBotModel::systemTimeUpdate(const Json::Value &time_update) {
    UPDATE_STRING_PROP(systemTime, time_update["system_time"]);
    UPDATE_STRING_PROP(timeZone, time_update["time_zone"]);
}

void KaitenBotModel::cancel(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        conn->jsonrpc.invoke("cancel", Json::Value(), std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::pauseResumePrint(QString action){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value(action.toStdString());
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::print(QString file_name){
    try{
        qDebug() << FL_STRM << "file_name: " << file_name;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["filepath"] = Json::Value(file_name.toStdString());
        json_params["ensure_build_plate_clear"] = Json::Value(false);
        json_params["transfer_wait"] = Json::Value(false);
        conn->jsonrpc.invoke("print", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::done(QString acknowledge_result){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value(acknowledge_result.toStdString());
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::loadFilament(const int kToolIndex, bool external, bool whilePrinting){
    try{
        qDebug() << FL_STRM << "tool_index: " << kToolIndex;
        qDebug() << FL_STRM << "external: " << external;;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);

        if(!whilePrinting) {
            json_params["tool_index"] = Json::Value(kToolIndex);
            json_params["external"] = Json::Value(external);
            conn->jsonrpc.invoke("load_filament", json_params, std::weak_ptr<JsonRpcCallback>());
        }
        else {
            json_params["method"] = Json::Value("load_filament");
            Json::Value json_args(Json::objectValue);
            json_args["tool_index"] = Json::Value(kToolIndex);
            json_args["external"] = Json::Value(external);
            json_params["params"] = Json::Value(json_args);
            conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
        }
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

// Call to let load_filament() know the fliament is extruding
void KaitenBotModel::loadFilamentStop(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value("stop_filament");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::unloadFilament(const int kToolIndex, bool external, bool whilePrinting){
    try{
        qDebug() << FL_STRM << "tool_index: " << kToolIndex;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        if(!whilePrinting) {
            json_params["tool_index"] = Json::Value(kToolIndex);
            json_params["external"] = Json::Value(external);
            conn->jsonrpc.invoke("unload_filament", json_params, std::weak_ptr<JsonRpcCallback>());
        }
        else {
            json_params["method"] = Json::Value("unload_filament");
            Json::Value json_args(Json::objectValue);
            json_args["tool_index"] = Json::Value(kToolIndex);
            json_params["params"] = Json::Value(json_args);
            conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
        }
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::assistedLevel(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        conn->jsonrpc.invoke("assisted_level", Json::Value(), std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::acknowledge_level(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value("acknowledge_level");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::continue_leveling(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value("continue_process");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::firmwareUpdateCheck(bool dont_force_check){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["only_notify"] = Json::Value(dont_force_check);
        conn->jsonrpc.invoke("update_available_firmware", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::installFirmware(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        conn->jsonrpc.invoke("download_and_install_firmware", Json::Value(), std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::installFirmwareFromPath(const QString file_path){
    try{
        qDebug() << FL_STRM << "file_name: " << file_path;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["filepath"] = Json::Value(file_path.toStdString());
        json_params["transfer_wait"] = Json::Value(false);
        conn->jsonrpc.invoke("brooklyn_upload", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::calibrateToolheads(QList<QString> axes){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        Json::Value axes_list(Json::arrayValue);

        for(int i = 0; i < axes.size(); i++)
            axes_list[i] = (axes.value(i)).toStdString();

        json_params["axes"] = Json::Value(axes_list);
        conn->jsonrpc.invoke("calibrate_toolheads", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::doNozzleCleaning(bool do_clean){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = do_clean ? Json::Value("do_cleaning") : Json::Value("skip_cleaning");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}


void KaitenBotModel::acknowledgeNozzleCleaned(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value("nozzle_cleaned");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::buildPlateState(bool state){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = state ? Json::Value("build_plate_installed") : Json::Value("build_plate_removed");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::query_status(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["machine_func"] = Json::Value("query_status");
        json_params["params"] = Json::Value(Json::objectValue);
        conn->jsonrpc.invoke("machine_query_command", json_params, m_queryStatusCb);
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::resetToFactory(bool clearCalibration){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["clear_calibration"] = Json::Value(clearCalibration);
        conn->jsonrpc.invoke("reset_to_factory", Json::Value(), std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::buildPlateCleared(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["method"] = Json::Value("build_plate_cleared");
        conn->jsonrpc.invoke("process_method", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::toggleWifi(bool enable){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        if (enable) {
            conn->jsonrpc.invoke("wifi_enable", Json::Value(), std::weak_ptr<JsonRpcCallback>());
        } else {
            conn->jsonrpc.invoke("wifi_disable", Json::Value(), std::weak_ptr<JsonRpcCallback>());
        }
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::scanWifi(bool forceRescan){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["force_rescan"] = Json::Value(forceRescan);
        conn->jsonrpc.invoke("wifi_scan", json_params, m_wifiCb);
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::connectWifi(QString path, QString password, QString name){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["path"] = Json::Value(path.toStdString());
        json_params["password"] = Json::Value(password.toStdString());
        json_params["name"] = Json::Value(name.toStdString());
        conn->jsonrpc.invoke("wifi_connect", json_params, m_wifiCb);
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::disconnectWifi(QString path) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["path"] = Json::Value(path.toStdString());
        conn->jsonrpc.invoke("wifi_disconnect", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::forgetWifi(QString path) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["path"] = Json::Value(path.toStdString());
        conn->jsonrpc.invoke("wifi_forget", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::addMakerbotAccount(QString username, QString makerbot_token) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["username"] = Json::Value(username.toStdString());
        json_params["makerbot_token"] = Json::Value(makerbot_token.toStdString());
        conn->jsonrpc.invoke(
                "add_makerbot_account",
                json_params,
                std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::getSpoolInfo(const int bayIndex){
  try{
      qDebug() << FL_STRM << "called";
      auto conn = m_conn.data();
      Json::Value json_params(Json::objectValue);
      json_params["bay_index"] = Json::Value(bayIndex);
      conn->jsonrpc.invoke(
              "get_spool_info",
              json_params,
              m_spoolInfoCb[bayIndex]);
  }
  catch(JsonRpcInvalidOutputStream &e){
      qWarning() << FFL_STRM << e.what();
  }
}

void KaitenBotModel::updateSpoolInfo(const int bayIndex){
  try{
      qDebug() << FL_STRM << "called";
      auto conn = m_conn.data();
      Json::Value json_params(Json::objectValue);
      json_params["bay_index"] = Json::Value(bayIndex);
      bayIndex ? spoolBUpdateFinishedSet(false) : spoolAUpdateFinishedSet(false);
      conn->jsonrpc.invoke(
              "update_spool_info",
              json_params,
              m_updateSpoolInfoCb[bayIndex]);
  }
  catch(JsonRpcInvalidOutputStream &e){
      qWarning() << FFL_STRM << e.what();
      bayIndex ? spoolBUpdateFinishedSet(true) : spoolAUpdateFinishedSet(true);
  }
}

void KaitenBotModel::getToolStats(const int index){
  try{
      qDebug() << FL_STRM << "called";
      auto conn = m_conn.data();
      Json::Value json_params(Json::objectValue);
      json_params["tool_index"] = Json::Value(index);
      conn->jsonrpc.invoke(
              "get_tool_usage_stats",
              json_params,
              m_toolStatsCb[index]);
  }
  catch(JsonRpcInvalidOutputStream &e){
      qWarning() << FFL_STRM << e.what();
  }
}

void KaitenBotModel::zipLogs(QString path) {
  try{
      qDebug() << FL_STRM << "called";
      auto conn = m_conn.data();
      Json::Value json_params(Json::objectValue);
      json_params["zip_path"] = Json::Value(path.toStdString());
      conn->jsonrpc.invoke(
              "zip_logs",
              json_params,
              std::weak_ptr<JsonRpcCallback>());
  }
  catch(JsonRpcInvalidOutputStream &e){
      qWarning() << FFL_STRM << e.what();
  }
}

void KaitenBotModel::changeMachineName(QString new_name) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["machine_name"] = Json::Value(new_name.toStdString());
        conn->jsonrpc.invoke("change_machine_name", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::getSystemTime() {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["notify"] = Json::Value(true);
        conn->jsonrpc.invoke("check_notify_system_time", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::setSystemTime(QString new_time) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["date_time"] = Json::Value(new_time.toStdString());
        conn->jsonrpc.invoke("set_system_time", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::setTimeZone(QString time_zone) {
    timeZoneSet(time_zone);
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["new_tz"] = Json::Value(time_zone.toStdString());
        conn->jsonrpc.invoke("set_tz", json_params, m_stzCb);
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::deauthorizeAllAccounts() {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        conn->jsonrpc.invoke("clear_authorized", Json::Value(), std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::preheatChamber(const int chamber_temperature) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        Json::Value temperature_list(Json::arrayValue);

        temperature_list[0] = 0;
        temperature_list[1] = 0;
        temperature_list[2] = chamber_temperature;

        json_params["temperature_settings"] = Json::Value(temperature_list);
        conn->jsonrpc.invoke("preheat", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}

void KaitenBotModel::moveAxis(QString axis, float distance, float speed) {
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();

        Json::Value json_params(Json::objectValue);
        Json::Value mach_params(Json::objectValue);

        mach_params["axis"] = Json::Value(axis.toStdString());
        mach_params["point_mm"] = Json::Value(distance);
        mach_params["mm_per_second"] = Json::Value(speed);
        mach_params["relative"] = Json::Value(true);
        json_params["machine_func"] = Json::Value("move_axis_upto_endstop");
        json_params["params"] = std::move(mach_params);
        json_params["ignore_tool_errors"] = Json::Value(true);

        conn->jsonrpc.invoke("machine_action_command", json_params, std::weak_ptr<JsonRpcCallback>());
    }
    catch(JsonRpcInvalidOutputStream &e){
        qWarning() << FFL_STRM << e.what();
    }
}


KaitenBotModel::KaitenBotModel(const char * socketpath) :
        m_conn(new LocalJsonRpc(socketpath)),
        m_sysNot(new SystemNotification(this)),
        m_sysInfoCb(new SysInfoCallback(this)),
        m_netNot(new NetStateNotification(this)),
        m_netStateCb(new NetStateCallback(this)),
        m_authReq(new AuthRequestMethod(this)),
        m_fwareUpNot(new FirmwareUpdateNotification(this)),
        m_allowUnkFw(new AllowUnknownFirmware(this)),
        m_prtFileVld(new PrintFileUpdate(this)),
        m_asstLvlNot(new AssistedLevelNotification(this)),
        m_asstLvlCb(new AssistedLevelCallback(this)),
        m_queryStatusNot(new QueryStatusNotification(this)),
        m_queryStatusCb(new QueryStatusCallback(this)),
        m_wifiResult(new WifiUpdateResult(this)),
        m_wifiCb(new WifiUpdateCallback(this)),
        m_spoolInfoCb{std::shared_ptr<SpoolInfoCallback>(
                              new SpoolInfoCallback(this, 0)),
                      std::shared_ptr<SpoolInfoCallback>(
                              new SpoolInfoCallback(this, 1))},
        m_updateSpoolInfoCb{std::shared_ptr<UpdateSpoolInfoCallback>(
                              new UpdateSpoolInfoCallback(this, 0)),
                      std::shared_ptr<UpdateSpoolInfoCallback>(
                              new UpdateSpoolInfoCallback(this, 1))},
        m_toolStatsCb{std::shared_ptr<ToolStatsCallback>(
                              new ToolStatsCallback(this, 0)),
                      std::shared_ptr<ToolStatsCallback>(
                              new ToolStatsCallback(this, 1))},
        m_matWarningNot(new UnknownMaterialNotification(this)),
        m_usbCopyCompleteNot(new UsbCopyCompleteNotification(this)),
        m_sysTimeNot(new SystemTimeNotification(this)),
        m_stzCb(new SetTimeZoneCallback()) {
    m_net.reset(new KaitenNetModel());
    m_process.reset(new KaitenProcessModel());

    auto conn = m_conn.data();
    conn->jsonrpc.addMethod("system_notification", m_sysNot);
    conn->jsonrpc.addMethod("state_notification", m_sysNot);
    conn->jsonrpc.addMethod("network_state_change", m_netNot);
    conn->jsonrpc.addMethod("authorize_user", m_authReq);
    conn->jsonrpc.addMethod("firware_updates_info_change", m_fwareUpNot);
    conn->jsonrpc.addMethod("allow_unknown_firmware", m_allowUnkFw);
    conn->jsonrpc.addMethod("print_file_valid", m_prtFileVld);
    conn->jsonrpc.addMethod("assisted_level_status", m_asstLvlNot);
    conn->jsonrpc.addMethod("material_warning", m_matWarningNot);
    conn->jsonrpc.addMethod("usb_copy_complete", m_usbCopyCompleteNot);
    conn->jsonrpc.addMethod("system_time_notification", m_sysTimeNot);

    connect(conn, &LocalJsonRpc::connected, this, &KaitenBotModel::connected);
    connect(conn, &LocalJsonRpc::disconnected, this, &KaitenBotModel::disconnected);
    connect(conn, &LocalJsonRpc::timeout, this, &KaitenBotModel::timeout);
}

void KaitenBotModel::sysInfoUpdate(const Json::Value &info) {
    dynamic_cast<KaitenNetModel*>(m_net.data())->sysInfoUpdate(info);
    dynamic_cast<KaitenProcessModel*>(m_process.data())->procUpdate(
        info["current_process"]);
    UPDATE_STRING_PROP(name, info["machine_name"]);

    if(!info.empty()){
      // Try to update extruder and chamber GUI values
      const Json::Value & kToolheads = info["toolheads"];
      if(kToolheads.isObject()){
        const Json::Value & kExtruder = kToolheads["extruder"];
        if(kExtruder.isArray() && kExtruder.size() >= 2){
          const Json::Value & kExtruderA = kExtruder[0], // Left Extruder
                            & kExtruderB = kExtruder[1]; // Right Extruder
          bool updating_extruder_firmware = false;
#define EXTRUDER_VAR_UPDATE(EXT_SYM) \
          if(kExtruder ## EXT_SYM.isObject()){ \
            /* Update GUI variables for extruder temps */ \
            UPDATE_INT_PROP(extruder ## EXT_SYM ## CurrentTemp, kExtruder ## EXT_SYM["current_temperature"]) \
            UPDATE_INT_PROP(extruder ## EXT_SYM ## TargetTemp, kExtruder ## EXT_SYM["target_temperature"]) \
            extruder ## EXT_SYM ## ToolTypeCorrectSet(kExtruder ## EXT_SYM["tool_type_correct"].asBool()); \
            extruder ## EXT_SYM ## PresentSet(kExtruder ## EXT_SYM["tool_present"].asBool()); \
            extruder ## EXT_SYM ## FilamentPresentSet(kExtruder ## EXT_SYM["filament_presence"].asBool()); \
            updating_extruder_firmware |= \
                kExtruder ## EXT_SYM["updating_extruder_firmware"].asBool(); \
            UPDATE_INT_PROP(extruderFirmwareUpdateProgress ## EXT_SYM, \
                            kExtruder ## EXT_SYM["extruder_firmware_update_progress"]) \
 \
            const Json::Value &kErrList = kExtruder ## EXT_SYM["error"]; \
            /* TODO(praveen) */ \
            /* The error and it's source are present in the error */ \
            /* dict so this is not the best way to do this. */ \
            extruder ## EXT_SYM ## OOFSet(checkError(kErrList, 80)); \
            extruder ## EXT_SYM ## JammedSet(checkError(kErrList, 81)); \
            if(kErrList.isArray() && kErrList.size() > 0) { \
              QString errStr; \
              for (const Json::Value err : kErrList) { \
                auto e = err.asString().c_str(); \
                errStr.append(e); \
                errStr.append(" "); \
              } \
              extruder ## EXT_SYM ## ErrorCodeSet(errStr); \
            } else { \
              extruder ## EXT_SYM ## ErrorCodeReset(); \
            } \
          }
          EXTRUDER_VAR_UPDATE(A)
          EXTRUDER_VAR_UPDATE(B)
#undef EXTRUDER_VAR_UPDATE
          updatingExtruderFirmwareSet(updating_extruder_firmware);
        }
        const Json::Value & kChamber = kToolheads["chamber"];
        if(kChamber.isArray() && kChamber.size() > 0){
          const Json::Value & kChamberA = kChamber[0];
          if(kChamberA.isObject()){
            // Update GUI variables for chamber temps
            UPDATE_INT_PROP(chamberCurrentTemp, kChamberA["current_temperature"])
            UPDATE_INT_PROP(chamberTargetTemp, kChamberA["target_temperature"])
            UPDATE_INT_PROP(chamberErrorCode, kChamberA["error"])
          }
        }
      }
      // Update filament bay status variables
      const Json::Value &kFilamentBay = info["filamentbays"];
      if(kFilamentBay.isArray()){
#define FILA_BAY_VAR_UPDATE(BAY_IDX, BAY_SYM, BAY_NUM) \
        if(kFilamentBay.size() > BAY_IDX){ \
          const Json::Value &kBay = kFilamentBay[BAY_IDX]; \
          if(kBay.isObject()){ \
            UPDATE_INT_PROP(filamentBay ## BAY_SYM ## Temp, kBay["temperature"]); \
            UPDATE_INT_PROP(filamentBay ## BAY_SYM ## Humidity, kBay["humidity"]); \
            filamentBay ## BAY_SYM ## FilamentPresentSet(kBay["filament_present"].asBool()); \
 \
            filamentBay ## BAY_SYM ## TagPresentSet(kBay["tag_present"].asBool()); \
            /* TODO(dev): using numbers and letters for extruder symbols */ \
            infoBay ## BAY_NUM ## TagPresentSet(kBay["tag_present"].asBool()); \
 \
            if (kBay.isMember("tag_uid")) { \
                UPDATE_STRING_PROP(filamentBay ## BAY_SYM ## TagUID, kBay["tag_uid"]); \
                UPDATE_STRING_PROP(infoBay ## BAY_NUM ## TagUID, kBay["tag_uid"]); \
            } \
 \
            filamentBay ## BAY_SYM ## TagVerifiedSet(kBay["tag_verified"].asBool()); \
            infoBay ## BAY_NUM ## TagVerifiedSet(kBay["tag_verified"].asBool()); \
 \
            filamentBay ## BAY_SYM ## TagVerificationDoneSet(kBay["verification_done"].asBool()); \
            infoBay ## BAY_NUM ## VerificationDoneSet(kBay["verification_done"].asBool()); \
 \
            UPDATE_INT_PROP(spool ## BAY_SYM ## AmountRemaining, kBay["filament_amount_remaining"]); \
 \
          } \
        }
        FILA_BAY_VAR_UPDATE(0, A, 1)
        FILA_BAY_VAR_UPDATE(1, B, 2)
#undef FILA_BAY_VAR_UPDATE
      }
      // Update disabled errors (door or lid for now) for the UI
      // to not complain before starting a print
      const Json::Value &kDisabledErrors = info["disabled_errors"];
      if(kDisabledErrors.isArray() && kDisabledErrors.size() > 0){
        for(const Json::Value error : kDisabledErrors){
          if(error.asString() == "door_interlock_triggered" ||
             error.asString() == "lid_interlock_triggered"){
            doorLidErrorDisabledSet(true);
          }
        }
      }
      else {
        doorLidErrorDisabledReset();
      }

      // TODO(chris): This bit is a mess...
      const Json::Value & version_dict = info["firmware_version"];
      const Json::Value & version_major = version_dict["major"];
      const Json::Value & version_minor = version_dict["minor"];
      const Json::Value & version_bugfix = version_dict["bugfix"];
      const Json::Value & version_build = version_dict["build"];
      if (version_major.isInt() && version_minor.isInt() &&
              version_bugfix.isInt() && version_build.isInt()) {
          std::stringstream version;
          version << version_major.asInt() << "."
                  << version_minor.asInt() << "."
                  << version_bugfix.asInt() << "."
                  << version_build.asInt();
          versionSet(version.str().c_str());
      } else {
          versionReset();
      }
    }
}

bool KaitenBotModel::checkError(const Json::Value error_list,
                                const int error_code) {
  if(error_list.isArray() && error_list.size() > 0) {
    for(size_t i = 0; i < error_list.size(); ++i) {
      const Json::Value & err = error_list[i];
      if(err.asInt() == error_code) {
        return true;
      }
    }
  }
  return false;
}

void KaitenBotModel::netUpdate(const Json::Value &state) {
    dynamic_cast<KaitenNetModel*>(m_net.data())->netUpdate(state);
}

void KaitenBotModel::firmwareUpdateNotif(const Json::Value &params) {
    if(!params.empty()){
        if(params["update_available"].asBool()) {
            firmwareUpdateAvailableSet(true);
            UPDATE_STRING_PROP(firmwareUpdateVersion, params["version"]);
            UPDATE_STRING_PROP(firmwareUpdateReleaseDate, params["release_date"]);
            UPDATE_STRING_PROP(firmwareUpdateReleaseNotes, params["release_notes"]);
        }
        else {
            firmwareUpdateAvailableReset();
        }
    }
}

void KaitenBotModel::printFileValidNotif(const Json::Value &params) {
    dynamic_cast<KaitenProcessModel*>(m_process.data())->printFileUpdate(params);
}

void KaitenBotModel::assistedLevelUpdate(const Json::Value &status) {
    dynamic_cast<KaitenProcessModel*>(m_process.data())->asstLevelUpdate(status);
}

void KaitenBotModel::wifiUpdate(const Json::Value &result) {
    dynamic_cast<KaitenNetModel*>(m_net.data())->wifiUpdate(result);
}

void KaitenBotModel::toolStatsUpdate(const Json::Value &result, const int index) {
    const Json::Value & res = result["result"];

    // :(
    switch(index) {
        case 0: {
            UPDATE_INT_PROP(extruderAShortRetractCount, res["short_retract_count"]);
            UPDATE_INT_PROP(extruderALongRetractCount, res["long_retract_count"]);
            UPDATE_INT_PROP(extruderAExtrusionDistance, res["extrusion_distance_mm"]);
            break;
        }
        case 1: {
            UPDATE_INT_PROP(extruderBShortRetractCount, res["short_retract_count"]);
            UPDATE_INT_PROP(extruderBLongRetractCount, res["long_retract_count"]);
            UPDATE_INT_PROP(extruderBExtrusionDistance, res["extrusion_distance_mm"]);
            break;
        }
    }
}

void KaitenBotModel::spoolUpdate(const Json::Value &result, const int index) {
    const Json::Value & res = result["result"];

    // :(
    switch(index) {
        case 0: {
            UPDATE_INT_PROP(spoolAOriginalAmount, res["original_amount"]);
            UPDATE_INT_PROP(spoolAVersion, res["version"]);
            UPDATE_INT_PROP(spoolAManufacturingLotCode, res["manufacturing_lot_code"]);
            UPDATE_INT_PROP(spoolAManufacturingDate, res["manufacturing_date"]);
            UPDATE_STRING_PROP(spoolASupplierCode, res["supplier_code"]);
            UPDATE_INT_PROP(spoolAMaterial, res["material_type"]);
            UPDATE_INT_PROP(spoolAChecksum, res["checksum"]);
            UPDATE_INT_LIST_PROP(spoolAColorRGB, res["material_color_rgb"]);
            UPDATE_STRING_PROP(spoolAColorName, res["material_color_name"]);

            UPDATE_INT_PROP(spoolAAmountRemaining, res["amount_remaining"]);
            UPDATE_INT_PROP(spoolAFirstLoadDate, res["first_load_date"]);
            UPDATE_INT_PROP(spoolAMaxHumidity, res["max_humidity"]);
            UPDATE_INT_PROP(spoolAMaxTemperature, res["max_temperature"]);
            UPDATE_INT_PROP(spoolASchemaVersion, res["rw_version"]);
            spoolADetailsReadySet(true);
            break;
        }
        case 1: {
            UPDATE_INT_PROP(spoolBOriginalAmount, res["original_amount"]);
            UPDATE_INT_PROP(spoolBVersion, res["version"]);
            UPDATE_INT_PROP(spoolBManufacturingLotCode, res["manufacturing_lot_code"]);
            UPDATE_INT_PROP(spoolBManufacturingDate, res["manufacturing_date"]);
            UPDATE_STRING_PROP(spoolBSupplierCode, res["supplier_code"]);
            UPDATE_INT_PROP(spoolBMaterial, res["material_type"]);
            UPDATE_INT_PROP(spoolBChecksum, res["checksum"]);
            UPDATE_INT_LIST_PROP(spoolBColorRGB, res["material_color_rgb"]);
            UPDATE_STRING_PROP(spoolBColorName, res["material_color_name"]);

            UPDATE_INT_PROP(spoolBAmountRemaining, res["amount_remaining"]);
            UPDATE_INT_PROP(spoolBFirstLoadDate, res["first_load_date"]);
            UPDATE_INT_PROP(spoolBMaxHumidity, res["max_humidity"]);
            UPDATE_INT_PROP(spoolBMaxTemperature, res["max_temperature"]);
            UPDATE_INT_PROP(spoolBSchemaVersion, res["rw_version"]);
            spoolBDetailsReadySet(true);
            break;
        }
    }
}

void KaitenBotModel::resetSpoolProperties(const int bayID) {
    switch(bayID) {
        case 1: {
            spoolADetailsReadyReset();
            spoolAOriginalAmountReset();
            spoolAVersionReset();
            spoolAManufacturingLotCodeReset();
            spoolAManufacturingDateReset();
            spoolASupplierCodeReset();
            spoolAMaterialReset();
            spoolAChecksumReset();
            spoolAColorRGBReset();
            spoolAColorNameReset();
            spoolAAmountRemainingReset();
            spoolAFirstLoadDateReset();
            spoolAMaxHumidityReset();
            spoolAMaxTemperatureReset();
            spoolASchemaVersionReset();
            spoolAUpdateFinishedReset();
            break;
        }
        case 2: {
            spoolBDetailsReadyReset();
            spoolBOriginalAmountReset();
            spoolBVersionReset();
            spoolBManufacturingLotCodeReset();
            spoolBManufacturingDateReset();
            spoolBSupplierCodeReset();
            spoolBMaterialReset();
            spoolBChecksumReset();
            spoolBColorRGBReset();
            spoolBColorNameReset();
            spoolBAmountRemainingReset();
            spoolBFirstLoadDateReset();
            spoolBMaxHumidityReset();
            spoolBMaxTemperatureReset();
            spoolBSchemaVersionReset();
            spoolBUpdateFinishedReset();
            break;
        }
    }
}

void KaitenBotModel::queryStatusUpdate(const Json::Value &info) {
    if(!info.empty()){
        const Json::Value &kChamber = info["chamber_status"];
        if(kChamber.isObject()){
            UPDATE_INT_PROP(infoChamberCurrentTemp, kChamber["current_temperature"]);
            UPDATE_INT_PROP(infoChamberTargetTemp, kChamber["target_temperature"]);
            UPDATE_INT_PROP(infoChamberFanASpeed, kChamber["fana_speed"]);
            UPDATE_INT_PROP(infoChamberFanBSpeed, kChamber["fanb_speed"]);
            UPDATE_INT_PROP(infoChamberHeaterATemp, kChamber["heatera_temperature"]);
            UPDATE_INT_PROP(infoChamberHeaterBTemp, kChamber["heaterb_temperature"]);
            UPDATE_INT_PROP(infoChamberError, kChamber["error"]);
        }

        const Json::Value &kFilamentBay = info["filamentbay_status"];
        if(kFilamentBay.isArray() && kFilamentBay.size() > 0){
            const Json::Value &kBayA = kFilamentBay[0],
                              &kBayB = kFilamentBay[1];
            if(kBayA.isObject()){
                UPDATE_INT_PROP(infoBay1Temp, kBayA["temperature"]);
                UPDATE_INT_PROP(infoBay1Humidity, kBayA["humidity"]);

                filamentBayAFilamentPresentSet(kBayA["filament_present"].asBool());
                infoBay1FilamentPresentSet(kBayA["filament_present"].asBool());

                filamentBayATagPresentSet(kBayA["tag_present"].asBool());
                infoBay1TagPresentSet(kBayA["tag_present"].asBool());

                if(!kBayA["tag_present"].asBool()) {
                    filamentBayATagUIDReset();
                    infoBay1TagUIDReset();
                }
                else {
                    UPDATE_STRING_PROP(filamentBayATagUID, kBayA["tag_uid"]);
                    UPDATE_STRING_PROP(infoBay1TagUID, kBayA["tag_uid"]);
                }

                filamentBayATagVerifiedSet(kBayA["tag_verified"].asBool());
                infoBay1TagVerifiedSet(kBayA["tag_verified"].asBool());

                filamentBayATagVerificationDoneSet(kBayA["verification_done"].asBool());
                infoBay1VerificationDoneSet(kBayA["verification_done"].asBool());

                UPDATE_INT_PROP(infoBay1Error, kBayA["error"]);
            }

            if(kBayB.isObject()){
                UPDATE_INT_PROP(infoBay2Temp, kBayB["temperature"]);
                UPDATE_INT_PROP(infoBay2Humidity, kBayB["humidity"]);

                filamentBayBFilamentPresentSet(kBayB["filament_present"].asBool());
                infoBay2FilamentPresentSet(kBayB["filament_present"].asBool());

                filamentBayBTagPresentSet(kBayB["tag_present"].asBool());
                infoBay2TagPresentSet(kBayB["tag_present"].asBool());

                if(!kBayB["tag_present"].asBool()) {
                    filamentBayBTagUIDReset();
                    infoBay2TagUIDReset();
                }
                else {
                    UPDATE_STRING_PROP(filamentBayBTagUID, kBayB["tag_uid"]);
                    UPDATE_STRING_PROP(infoBay2TagUID, kBayB["tag_uid"]);
                }

                filamentBayBTagVerifiedSet(kBayB["tag_verified"].asBool());
                infoBay2TagVerifiedSet(kBayB["tag_verified"].asBool());

                filamentBayBTagVerificationDoneSet(kBayB["verification_done"].asBool());
                infoBay2VerificationDoneSet(kBayB["verification_done"].asBool());

                UPDATE_INT_PROP(infoBay2Error, kBayB["error"]);
            }
        }

        infoDoorActivatedSet(info["door_activated"].asBool());
        infoLidActivatedSet(info["lid_activated"].asBool());

        const Json::Value &kTopBunkFanRPM = info["top_bunk_fan_rpm"];
        if(kTopBunkFanRPM.isArray() && kTopBunkFanRPM.size() > 0){
            infoTopBunkFanARPMSet(kTopBunkFanRPM[0].asInt());
            infoTopBunkFanBRPMSet(kTopBunkFanRPM[1].asInt());
        }

        const Json::Value &kMotionStatus = info["motion_status"];
        if(kMotionStatus.isObject()){
            const Json::Value &kAxesEnabled = kMotionStatus["axis_enabled"];
            if(kAxesEnabled.isArray() && kAxesEnabled.size() > 0){
                infoAxisXEnabledSet(kAxesEnabled[0].asBool());
                infoAxisYEnabledSet(kAxesEnabled[1].asBool());
                infoAxisZEnabledSet(kAxesEnabled[2].asBool());
                infoAxisAEnabledSet(kAxesEnabled[3].asBool());
                infoAxisBEnabledSet(kAxesEnabled[4].asBool());
                infoAxisAAEnabledSet(kAxesEnabled[5].asBool());
                infoAxisBBEnabledSet(kAxesEnabled[6].asBool());
            }

            const Json::Value &kEndstopActivated = kMotionStatus["endstop_activated"];
            if(kEndstopActivated.isArray() && kEndstopActivated.size() > 0){
                infoAxisXEndStopActiveSet(kEndstopActivated[0].asBool());
                infoAxisYEndStopActiveSet(kEndstopActivated[1].asBool());
                infoAxisZEndStopActiveSet(kEndstopActivated[2].asBool());
                infoAxisAEndStopActiveSet(kEndstopActivated[3].asBool());
                infoAxisBEndStopActiveSet(kEndstopActivated[4].asBool());
                infoAxisAAEndStopActiveSet(kEndstopActivated[5].asBool());
                infoAxisBBEndStopActiveSet(kEndstopActivated[6].asBool());
            }

            const Json::Value &kAxesPosition = kMotionStatus["position"];
            if(kAxesPosition.isArray() && kAxesPosition.size() > 0){
                UPDATE_FLOAT_PROP(infoAxisXPosition, kAxesPosition[0]);
                UPDATE_FLOAT_PROP(infoAxisYPosition, kAxesPosition[1]);
                UPDATE_FLOAT_PROP(infoAxisZPosition, kAxesPosition[2]);
                UPDATE_FLOAT_PROP(infoAxisAPosition, kAxesPosition[3]);
                UPDATE_FLOAT_PROP(infoAxisBPosition, kAxesPosition[4]);
                UPDATE_FLOAT_PROP(infoAxisAAPosition, kAxesPosition[5]);
                UPDATE_FLOAT_PROP(infoAxisBBPosition, kAxesPosition[6]);
            }
        }

        const Json::Value &kToolheads = info["toolhead_status"];
        if(kToolheads.isArray() && kToolheads.size() > 0){
            const Json::Value &kToolheadA = kToolheads[0],
                              &kToolheadB = kToolheads[1];

            if(kToolheadA.isObject()){
               infoToolheadAAttachedSet(kToolheadA["attached"].asBool());
               infoToolheadAFilamentPresentSet(kToolheadA["filament_presence"].asBool());
               infoToolheadAFilamentJamEnabledSet(kToolheadA["filament_jam_enabled"].asBool());
               UPDATE_INT_PROP(infoToolheadACurrentTemp, kToolheadA["current_temperature"]);
               UPDATE_INT_PROP(infoToolheadATargetTemp, kToolheadA["target_temperature"]);
               UPDATE_INT_PROP(infoToolheadAEncoderTicks, kToolheadA["encoder_ticks"]);
               UPDATE_INT_PROP(infoToolheadAActiveFanRPM, kToolheadA["active_fan_rpm"]);
               UPDATE_INT_PROP(infoToolheadAGradientFanRPM, kToolheadA["gradient_fan_rpm"]);
               UPDATE_FLOAT_PROP(infoToolheadAHESValue, kToolheadA["hes_value"]);

               const Json::Value &kErrList = kToolheadA["error"];
               if(kErrList.isArray() && kErrList.size() > 0) {
                  QString errStr;
                  for (const Json::Value err : kErrList) {
                    errStr.append(err.asString().c_str());
                    errStr.append(" ");
                  }
                  infoToolheadAErrorSet(errStr);
               } else {
                  infoToolheadAErrorReset();
               }
            }

            if(kToolheadB.isObject()){
               infoToolheadBAttachedSet(kToolheadB["attached"].asBool());
               infoToolheadBFilamentPresentSet(kToolheadB["filament_presence"].asBool());
               infoToolheadBFilamentJamEnabledSet(kToolheadB["filament_jam_enabled"].asBool());
               UPDATE_INT_PROP(infoToolheadBCurrentTemp, kToolheadB["current_temperature"]);
               UPDATE_INT_PROP(infoToolheadBTargetTemp, kToolheadB["target_temperature"]);
               UPDATE_INT_PROP(infoToolheadBEncoderTicks, kToolheadB["encoder_ticks"]);
               UPDATE_INT_PROP(infoToolheadBActiveFanRPM, kToolheadB["active_fan_rpm"]);
               UPDATE_INT_PROP(infoToolheadBGradientFanRPM, kToolheadB["gradient_fan_rpm"]);
               UPDATE_FLOAT_PROP(infoToolheadBHESValue, kToolheadB["hes_value"]);

               const Json::Value &kErrList = kToolheadB["error"];
               if(kErrList.isArray() && kErrList.size() > 0) {
                  QString errStr;
                  for (const Json::Value err : kErrList) {
                    errStr.append(err.asString().c_str());
                    errStr.append(" ");
                  }
                  infoToolheadBErrorSet(errStr);
               } else {
                  infoToolheadBErrorReset();
               }
            }
        }
    }
}

void KaitenBotModel::connected() {
    // TODO: Kaiten codegen?
    m_conn->jsonrpc.invoke("get_system_information", Json::Value(), m_sysInfoCb);
    m_conn->jsonrpc.invoke("network_state", Json::Value(), m_netStateCb);
    // TODO: Wait for callbacks before setting state to connected
    m_conn->jsonrpc.invoke("register_lcd", Json::Value(), std::weak_ptr<JsonRpcCallback>());

    Json::Value json_params(Json::objectValue);
    json_params["notify"] = Json::Value(true);
    m_conn->jsonrpc.invoke("check_notify_system_time", json_params, std::weak_ptr<JsonRpcCallback>());

    stateSet(ConnectionState::Connected);
}

void KaitenBotModel::disconnected() {
    stateSet(ConnectionState::Disconnected);
}

void KaitenBotModel::timeout() {
    stateSet(ConnectionState::TimedOut);
}

void KaitenBotModel::forceSyncFile(QString path) {
    int fd = open(path.toStdString().c_str(), O_APPEND);
    if (fd < 0) {
        LOG(error) << "Failed to sync file " << path.toStdString() << ": "
                   << errno << ": " << strerror(errno);
        return;
    }
    fsync(fd);
    close(fd);
}

void KaitenBotModel::shutdown() {
    system("poweroff");
}

BotModel * makeKaitenBotModel(const char * socketpath) {
    return dynamic_cast<BotModel *>(new KaitenBotModel(socketpath));
}
