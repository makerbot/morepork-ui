// Copyright 2017 Makerbot Industries

#include "kaiten_bot_model.h"

#include <memory>
#include <sstream>

#include "impl_util.h"
#include "kaiten_net_model.h"
#include "kaiten_process_model.h"
#include "local_jsonrpc.h"
#include "error_utils.h"

class KaitenBotModel : public BotModel {
  public:
    KaitenBotModel(const char * socketpath);
    void sysInfoUpdate(const Json::Value & info);
    void netUpdate(const Json::Value & info);
    void authRequestUpdate(const Json::Value &request);
    void firmwareUpdateNotif(const Json::Value & firmware_info);
    void printFileValidNotif(const Json::Value &info);
    void assistedLevelUpdate(const Json::Value & status);
    void queryStatusUpdate(const Json::Value & info);
    void cancel();
    void pauseResumePrint(QString action);
    void print(QString file_name);
    void done(QString acknowledge_result);
    void loadFilament(const int kToolIndex, bool external, bool whilePrinting);
    void loadFilamentStop();
    void unloadFilament(const int kToolIndex, bool external, bool whilePrinting);
    void assistedLevel();
    std::shared_ptr<JsonRpcMethod::Response> m_authResp;
    void respondAuthRequest(QString response);
    void firmwareUpdateCheck(bool dont_force_check);
    void installFirmware();
    void calibrateToolheads(QList<QString> axes);
    void buildPlateState(bool state);
    void acknowledge_level();
    void query_status();

    QScopedPointer<LocalJsonRpc, QScopedPointerDeleteLater> m_conn;
    void connected();
    void disconnected();
    void timeout();

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
            Json::Value json_params(Json::objectValue);
            json_params = Json::Value("allow");
            response->sendResult(json_params);
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
};

void KaitenBotModel::authRequestUpdate(const Json::Value &request){
    isAuthRequestPendingSet(true);
    UPDATE_STRING_PROP(username, request["username"]);
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
        m_queryStatusCb(new QueryStatusCallback(this)) {
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
          if(kExtruderA.isObject()){
            // Update GUI variables for extruder A temps
            UPDATE_INT_PROP(extruderACurrentTemp, kExtruderA["current_temperature"])
            UPDATE_INT_PROP(extruderATargetTemp, kExtruderA["target_temperature"])
            kExtruderA["tool_present"].asBool() ?
                extruderAPresentSet(true) : extruderAPresentSet(false);
            kExtruderA["filament_presence"].asBool() ? 
                extruderAFilamentPresentSet(true) : extruderAFilamentPresentSet(false);
            updating_extruder_firmware |=
                kExtruderA["updating_extruder_firmware"].asBool();
            UPDATE_INT_PROP(extruderFirmwareUpdateProgressA,
                            kExtruderA["extruder_firmware_update_progress"])
          }
          if(kExtruderB.isObject()){
            // Update GUI variables for extruder B temps
            UPDATE_INT_PROP(extruderBCurrentTemp, kExtruderB["current_temperature"])
            UPDATE_INT_PROP(extruderBTargetTemp, kExtruderB["target_temperature"])
            kExtruderB["tool_present"].asBool() ?
                extruderBPresentSet(true) : extruderBPresentSet(false);
            kExtruderB["filament_presence"].asBool() ? 
                extruderBFilamentPresentSet(true) : extruderBFilamentPresentSet(false);
            updating_extruder_firmware |=
                kExtruderB["updating_extruder_firmware"].asBool();
            UPDATE_INT_PROP(extruderFirmwareUpdateProgressB,
                            kExtruderB["extruder_firmware_update_progress"])
          }
          updatingExtruderFirmwareSet(updating_extruder_firmware);
        }
        const Json::Value & kChamber = kToolheads["chamber"];
        if(kChamber.isArray() && kChamber.size() > 0){
          const Json::Value & kChamberA = kChamber[0];
          if(kChamberA.isObject()){
            // Update GUI variables for chamber temps
            UPDATE_INT_PROP(chamberCurrentTemp, kChamberA["current_temperature"])
            UPDATE_INT_PROP(chamberTargetTemp, kChamberA["target_temperature"])
          }
        }
      }
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
                kBayA["filament_present"].asBool() ? infoBay1FilamentPresentSet(true) :
                                                     infoBay1FilamentPresentSet(false);
                kBayA["tag_present"].asBool() ? infoBay1TagPresentSet(true) :
                                                infoBay1TagPresentSet(false);
                UPDATE_STRING_PROP(infoBay1TagUID, kBayA["tag_uid"]);
                UPDATE_INT_PROP(infoBay1Error, kBayA["error"]);
            }
            if(kBayB.isObject()){
                UPDATE_INT_PROP(infoBay2Temp, kBayB["temperature"]);
                UPDATE_INT_PROP(infoBay2Humidity, kBayB["humidity"]);
                kBayB["filament_present"].asBool() ? infoBay2FilamentPresentSet(true) :
                                                     infoBay2FilamentPresentSet(false);
                kBayB["tag_present"].asBool() ? infoBay2TagPresentSet(true) :
                                                infoBay2TagPresentSet(false);
                UPDATE_STRING_PROP(infoBay2TagUID, kBayB["tag_uid"]);
                UPDATE_INT_PROP(infoBay2Error, kBayB["error"]);
            }
        }

        info["door_activated"].asBool() ? infoDoorActivatedSet(true) :
                                          infoDoorActivatedSet(false);
        info["lid_activated"].asBool() ? infoLidActivatedSet(true) :
                                         infoLidActivatedSet(false);

        const Json::Value &kMotionStatus = info["motion_status"];
        if(kMotionStatus.isObject()){
            const Json::Value &kAxesEnabled = kMotionStatus["axis_enabled"];
            if(kAxesEnabled.isArray() && kAxesEnabled.size() > 0){
                kAxesEnabled[0].asBool() ? infoAxisXEnabledSet(true) : infoAxisXEnabledSet(false);
                kAxesEnabled[1].asBool() ? infoAxisYEnabledSet(true) : infoAxisYEnabledSet(false);
                kAxesEnabled[2].asBool() ? infoAxisZEnabledSet(true) : infoAxisZEnabledSet(false);
                kAxesEnabled[3].asBool() ? infoAxisAEnabledSet(true) : infoAxisAEnabledSet(false);
                kAxesEnabled[4].asBool() ? infoAxisBEnabledSet(true) : infoAxisBEnabledSet(false);
                kAxesEnabled[5].asBool() ? infoAxisAAEnabledSet(true) : infoAxisAAEnabledSet(false);
                kAxesEnabled[6].asBool() ? infoAxisBBEnabledSet(true) : infoAxisBBEnabledSet(false);
            }

            const Json::Value &kEndstopActivated = kMotionStatus["endstop_activated"];
            if(kEndstopActivated.isArray() && kEndstopActivated.size() > 0){
                kEndstopActivated[0].asBool() ? infoAxisXEndStopActiveSet(true) : infoAxisXEndStopActiveSet(false);
                kEndstopActivated[1].asBool() ? infoAxisYEndStopActiveSet(true) : infoAxisYEndStopActiveSet(false);
                kEndstopActivated[2].asBool() ? infoAxisZEndStopActiveSet(true) : infoAxisZEndStopActiveSet(false);
                kEndstopActivated[3].asBool() ? infoAxisAEndStopActiveSet(true) : infoAxisAEndStopActiveSet(false);
                kEndstopActivated[4].asBool() ? infoAxisBEndStopActiveSet(true) : infoAxisBEndStopActiveSet(false);
                kEndstopActivated[5].asBool() ? infoAxisAAEndStopActiveSet(true) : infoAxisAAEndStopActiveSet(false);
                kEndstopActivated[6].asBool() ? infoAxisBBEndStopActiveSet(true) : infoAxisBBEndStopActiveSet(false);
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
               kToolheadA["attached"].asBool() ? infoToolheadAAttachedSet(true) :
                                                 infoToolheadAAttachedSet(false);
               kToolheadA["filament_presence"].asBool() ? infoToolheadAFilamentPresentSet(true) :
                                                          infoToolheadAFilamentPresentSet(false);
               kToolheadA["filament_jam_enabled"].asBool() ? infoToolheadAFilamentJamEnabledSet(true) :
                                                             infoToolheadAFilamentJamEnabledSet(false);
               UPDATE_INT_PROP(infoToolheadACurrentTemp, kToolheadA["current_temperature"]);
               UPDATE_INT_PROP(infoToolheadATargetTemp, kToolheadA["target_temperature"]);
               UPDATE_INT_PROP(infoToolheadAActiveFanRPM, kToolheadA["active_fan_rpm"]);
               UPDATE_INT_PROP(infoToolheadAGradientFanRPM, kToolheadA["gradient_fan_rpm"]);
               UPDATE_FLOAT_PROP(infoToolheadAHESValue, kToolheadA["hes_value"]);
               UPDATE_INT_PROP(infoToolheadAError, kToolheadA["error"]);
            }

            if(kToolheadB.isObject()){
               kToolheadB["attached"].asBool() ? infoToolheadBAttachedSet(true) :
                                                 infoToolheadBAttachedSet(false);
               kToolheadB["filament_presence"].asBool() ? infoToolheadBFilamentPresentSet(true) :
                                                          infoToolheadBFilamentPresentSet(false);
               kToolheadB["filament_jam_enabled"].asBool() ? infoToolheadBFilamentJamEnabledSet(true) :
                                                             infoToolheadBFilamentJamEnabledSet(false);
               UPDATE_INT_PROP(infoToolheadBCurrentTemp, kToolheadB["current_temperature"]);
               UPDATE_INT_PROP(infoToolheadBTargetTemp, kToolheadB["target_temperature"]);
               UPDATE_INT_PROP(infoToolheadBActiveFanRPM, kToolheadB["active_fan_rpm"]);
               UPDATE_INT_PROP(infoToolheadBGradientFanRPM, kToolheadB["gradient_fan_rpm"]);
               UPDATE_FLOAT_PROP(infoToolheadBHESValue, kToolheadB["hes_value"]);
               UPDATE_INT_PROP(infoToolheadBError, kToolheadB["error"]);

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
    stateSet(ConnectionState::Connected);
}

void KaitenBotModel::disconnected() {
    stateSet(ConnectionState::Disconnected);
}

void KaitenBotModel::timeout() {
    stateSet(ConnectionState::TimedOut);
}

BotModel * makeKaitenBotModel(const char * socketpath) {
    return dynamic_cast<BotModel *>(new KaitenBotModel(socketpath));
}
