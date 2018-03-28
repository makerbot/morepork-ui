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
    void cancel();
    void pausePrint();
    void print(QString file_name);
    void done(QString acknowledge_result);
    void loadFilament(const int kToolIndex);
    void loadFilamentStop();
    void unloadFilament(const int kToolIndex);
    void assistedLevel();
    std::shared_ptr<JsonRpcMethod::Response> m_authResp;
    void respondAuthRequest(QString response);
    void firmwareUpdateCheck(bool dont_force_check);
    void installFirmware();

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

void KaitenBotModel::pausePrint(){
    try{
        qDebug() << FL_STRM << "called";
        auto conn = m_conn.data();
        conn->jsonrpc.invoke("pause", Json::Value(), std::weak_ptr<JsonRpcCallback>());
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
        qWarning() << FL_STRM << e.what();
    }
}

void KaitenBotModel::loadFilament(const int kToolIndex){
    try{
        qDebug() << FL_STRM << "tool_index: " << kToolIndex;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["tool_index"] = Json::Value(kToolIndex);
        conn->jsonrpc.invoke("load_filament", json_params, std::weak_ptr<JsonRpcCallback>());
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

void KaitenBotModel::unloadFilament(const int kToolIndex){
    try{
        qDebug() << FL_STRM << "tool_index: " << kToolIndex;
        auto conn = m_conn.data();
        Json::Value json_params(Json::objectValue);
        json_params["tool_index"] = Json::Value(kToolIndex);
        conn->jsonrpc.invoke("unload_filament", json_params, std::weak_ptr<JsonRpcCallback>());
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
        m_asstLvlCb(new AssistedLevelCallback(this)) {
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
          const Json::Value & kExtruderA = kExtruder[0], // Right Extruder
                            & kExtruderB = kExtruder[1]; // Left Extruder
          if(kExtruderA.isObject()){
            // Update GUI variables for extruder A temps
            UPDATE_INT_PROP(extruderACurrentTemp, kExtruderA["current_temperature"])
            UPDATE_INT_PROP(extruderATargetTemp, kExtruderA["target_temperature"])
          }
          if(kExtruderB.isObject()){
            // Update GUI variables for extruder B temps
            UPDATE_INT_PROP(extruderBCurrentTemp, kExtruderB["current_temperature"])
            UPDATE_INT_PROP(extruderBTargetTemp, kExtruderB["target_temperature"])
          }
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
