// Copyright 2017 MakerBot Industries

#include <memory>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

// TODO: We should probably be able to set this up so that
//       the qrc thing works for all builds...
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#include "../host/host_model.h"
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/host/host_main.qml")
#define MOREPORK_BOT_MODEL makeHostBotModel()
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

    // So, basically, our UI is upside down when the one
    // is compared on the bot, to that of test in qtcreator.
    // So, that correction is done here
    #ifndef MOREPORK_UI_QT_CREATOR_BUILD
        QObject *rootObject = engine.rootObjects().first();
        QObject *qmlObject = rootObject->findChild<QObject*>("testLayout");
        if (qmlObject) {
            qmlObject->setProperty("rotation", 180);
        } else {
            qCritical() << "Cannot find testLayout";
        }
    #endif
    return qapp.exec();
}
