// Copyright 2017 Makerbot Industries

#include "kaiten_bot_model.h"

#include <memory>
#include <sstream>

#include "impl_util.h"
#include "kaiten_net_model.h"
#include "kaiten_process_model.h"
#include "local_jsonrpc.h"
#include "../error_utils.h"


class KaitenBotModel : public BotModel {
  public:
    KaitenBotModel(const char * socketpath);
    void sysInfoUpdate(const Json::Value & info);
    void netUpdate(const Json::Value & info);
    void cancel();
    void pausePrint();
    void print(QString file_name);

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
};

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
        json_params["filepath"] = Json::Value(std::string("/home/things/") + file_name.toStdString());
        json_params["ensure_build_plate_clear"] = Json::Value(false);
        json_params["transfer_wait"] = Json::Value(false);
        conn->jsonrpc.invoke("print", json_params, std::weak_ptr<JsonRpcCallback>());
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
        m_netStateCb(new NetStateCallback(this)) {
    m_net.reset(new KaitenNetModel());
    m_process.reset(new KaitenProcessModel());

    auto conn = m_conn.data();
    conn->jsonrpc.addMethod("system_notification", m_sysNot);
    conn->jsonrpc.addMethod("state_notification", m_sysNot);
    conn->jsonrpc.addMethod("network_state_change", m_netNot);

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
      if(!kToolheads.empty() && kToolheads.isObject()){
        const Json::Value & kExtruder = kToolheads["extruder"];
        if(!kExtruder.empty() && kExtruder.isArray()){
          const Json::Value & kExtruderA = kExtruder[0], // Right Extruder
                            & kExtruderB = kExtruder[1]; // Left Extruder
          if(!kExtruderA.empty() && kExtruderA.isObject()){
          // Update GUI variables for extruder A temps
            const Json::Value & kExtACurrTemp = kExtruderA["current_temperature"];
            if(kExtACurrTemp.isInt())
                extruderACurrentTempSet(QString::number(kExtACurrTemp.asInt()) + "°C");
            const Json::Value & kExtATargTemp = kExtruderA["target_temperature"];
            if(kExtATargTemp.isInt())
                extruderATargetTempSet(QString::number(kExtATargTemp.asInt()) + "°C");
          }
          if(!kExtruderB.empty() && kExtruderB.isObject()){
            // Update GUI variables for extruder B temps
            const Json::Value & kExtBCurrTemp = kExtruderB["current_temperature"];
            if(kExtBCurrTemp.isInt())
                extruderBCurrentTempSet(QString::number(kExtBCurrTemp.asInt()) + "°C");
            const Json::Value & kExtBTargTemp = kExtruderB["target_temperature"];
            if(kExtBTargTemp.isInt())
                extruderBTargetTempSet(QString::number(kExtBTargTemp.asInt()) + "°C");
          }
        }
        const Json::Value & kChamber = kToolheads["chamber"];
        if(!kChamber.empty() && kChamber.isArray()){
          const Json::Value & kChamberA = kChamber[0];
          if(!kChamberA.empty() && kChamberA.isObject()){
            // Update GUI variables for chamber temps
            const Json::Value & kChamberCurrTemp = kChamberA["current_temperature"];
            if(kChamberCurrTemp.isInt())
                chamberCurrentTempSet(QString::number(kChamberCurrTemp.asInt()) + "°C");
            const Json::Value & kChamberTargTemp = kChamberA["target_temperature"];
            if(kChamberTargTemp.isInt())
                chamberTargetTempSet(QString::number(kChamberTargTemp.asInt()) + "°C");
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

void KaitenBotModel::connected() {
    // TODO: Kaiten codegen?
    m_conn->jsonrpc.invoke(
        "get_system_information", Json::Value(), m_sysInfoCb);
    m_conn->jsonrpc.invoke("network_state", Json::Value(), m_netStateCb);
    // TODO: Wait for callbacks before setting state to connected
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
