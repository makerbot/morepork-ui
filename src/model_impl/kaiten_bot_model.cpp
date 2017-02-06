// Copyright 2017 Makerbot Industries

#include "kaiten_bot_model.h"

#include <memory>

#include "impl_util.h"
#include "kaiten_net_model.h"
#include "local_jsonrpc.h"

class KaitenBotModel : public BotModel {
  public:
    KaitenBotModel(const char * socketpath);
    void sysInfoUpdate(const Json::Value & info);
    void netUpdate(const Json::Value & info);
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
};

KaitenBotModel::KaitenBotModel(const char * socketpath) :
        m_conn(socketpath),
        m_sysNot(new SystemNotification(this)),
        m_netNot(new NetStateNotification(this)) {
    m_net.reset(new KaitenNetModel());

    m_conn.jsonrpc.addMethod("system_notification", m_sysNot);
    m_conn.jsonrpc.addMethod("state_notification", m_sysNot);
    m_conn.jsonrpc.addMethod("network_state_change", m_netNot);
}

void KaitenBotModel::sysInfoUpdate(const Json::Value &info) {
    dynamic_cast<KaitenNetModel*>(m_net.data())->sysInfoUpdate(info);
    UPDATE_STRING_PROP(name, info["machine_name"]);
}

void KaitenBotModel::netUpdate(const Json::Value &state) {
    dynamic_cast<KaitenNetModel*>(m_net.data())->netUpdate(state);
}

BotModel * makeKaitenBotModel(const char * socketpath) {
    return dynamic_cast<BotModel *>(new KaitenBotModel(socketpath));
}
