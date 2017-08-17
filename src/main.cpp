// Copyright 2017 MakerBot Industries

#include <memory>

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>

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

    // Parse arguments
    QCommandLineParser parser;
    parser.setApplicationDescription("Test helper");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("Test",
      QCoreApplication::translate("main", "Running test build"));
    QCommandLineOption test_option(QStringList() << "t"
      << "test_build", QCoreApplication::translate("main",
      "Build is test type"));
    parser.addOption(test_option);
    parser.process(qapp);

    QQmlApplicationEngine engine;

    QScopedPointer<BotModel, QScopedPointerDeleteLater> bot(MOREPORK_BOT_MODEL);
    engine.rootContext()->setContextProperty("bot", bot.data());

    engine.load(MOREPORK_UI_QML_MAIN);

    // So, basically, our UI is upside down when the one
    // is compared on the bot, to that of test in qtcreator.
    // We have two builds, makerbot-ui-test will render
    // right side up on qtcreater, and
    // makerbot-ui will build right side up on the bot
    bool is_test_build = parser.isSet(test_option);
    QObject *rootObject = engine.rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject*>("testLayout");
    if (qmlObject) {
        if (!is_test_build) {
            qmlObject->setProperty("rotation", 180);
        }
    } else {
        qCritical() << "Cannot find testLayout";
    }
    return qapp.exec();
}
