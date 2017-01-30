// Copyright 2017 Makerbot Industries

#include "kaiten_bot_model.h"

#include <memory>

#include <mbcoreutils/jsoncpp_wrappers.h>
#include "local_jsonrpc.h"

class KaitenBotModel : public BotModel {
  public:
    KaitenBotModel(const char * socketpath);
    void sysInfoUpdate(const Json::Value & info);
    LocalJsonRpc m_conn;

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
};

// Helper macros to update model properties based on json values.
// If the json value is of the right type we update otherwise we
// reset to default.
#define UPDATE_STRING_PROP(PROP, JSON_VAL) \
    do { \
        auto v = (JSON_VAL); \
        if (v.isString()) { \
            PROP ## Set(v.asString().c_str()); \
        } else { \
            PROP ## Reset(); \
        } \
    } while (0)

KaitenBotModel::KaitenBotModel(const char * socketpath) :
        m_conn(socketpath),
        m_sysNot(new SystemNotification(this)) {
    m_conn.jsonrpc.addMethod("system_notification", m_sysNot);
    m_conn.jsonrpc.addMethod("state_notification", m_sysNot);
}

void KaitenBotModel::sysInfoUpdate(const Json::Value &info) {
    UPDATE_STRING_PROP(ipAddr, info["ip"]);
    UPDATE_STRING_PROP(name, info["machine_name"]);
}

BotModel * makeKaitenBotModel(const char * socketpath) {
    return dynamic_cast<BotModel *>(new KaitenBotModel(socketpath));
}
