// Copyright 2017 MakerBot Industries

#include <memory>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

// TODO: We should probably be able to set this up so that
//       the qrc thing works for all builds...
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#include "model/bot_model.h"
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/host/host_main.qml")
#define MOREPORK_BOT_MODEL makeBotModel()
#else
#include "model_impl/kaiten_bot_model.h"
#define MOREPORK_UI_QML_MAIN "/usr/share/morepork_ui/MoreporkUI.qml"
#define MOREPORK_BOT_MODEL makeKaitenBotModel("/tmp/kaiten.socket")
#endif

int main(int argc, char ** argv)
{
    QGuiApplication qapp(argc, argv);
    QQmlApplicationEngine engine;

    QScopedPointer<BotModel, QScopedPointerDeleteLater> bot(MOREPORK_BOT_MODEL);
    engine.rootContext()->setContextProperty("bot", bot.data());

    engine.load(MOREPORK_UI_QML_MAIN);

    return qapp.exec();
}
