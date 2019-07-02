// Copyright 2017 MakerBot Industries
#include <memory>

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>

#include "ui_translator.h"
#include "logger.h"
#include "logging.h"
#include "network.h"

// TODO: We should probably be able to set this up so that
//       the qrc thing works for all builds...
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#include <QDirIterator>
#include <QFileInfo>
#include <QFontDatabase>
#include "host/host_model.h"
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/host/host_main.qml")
#define MOREPORK_BOT_MODEL makeHostBotModel()
#define MOREPORK_LOGGER makeLogger()
#else
#include "model_impl/kaiten_bot_model.h"
#include "model_impl/bot_logger.h"
#define MOREPORK_UI_QML_MAIN "/usr/share/morepork_ui/MoreporkUI.qml"
#define MOREPORK_BOT_MODEL makeKaitenBotModel("/tmp/kaiten.socket")
#define MOREPORK_LOGGER makeBotLogger()
void msgHandler(QtMsgType type,
                const QMessageLogContext & context,
                const QString &msg) {
    LOG(info) << msg.toStdString();
}
#endif
#include "fre_tracker.h"
#include "parsed_qml_enums.h"
#include "storage/storage.h"

int main(int argc, char ** argv) {
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
#ifndef MOREPORK_UI_QT_CREATOR_BUILD
    qInstallMessageHandler(msgHandler);
#endif
    QGuiApplication qapp(argc, argv);
    // This includes objects of classes defined in parsed_qml_enums.h
    // so QML can use cpp defined enumerations with namespaces
    QML_ENUM_OBJECTS

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
    QDirIterator it(MOREPORK_ROOT_DIR "/fonts");
    while(it.hasNext()) {
        if(QFileInfo(it.next()).suffix() == "otf" ||
           QFileInfo(it.next()).suffix() == "ttf") {
            QFontDatabase::addApplicationFont(it.fileInfo().absoluteFilePath());
        }
    }
#endif

    QScopedPointer<BotModel, QScopedPointerDeleteLater> bot(MOREPORK_BOT_MODEL);
    MoreporkStorage storage;
    FreTracker fre_tracker;
    QLocale::setDefault(QLocale(QStringLiteral("en_GB")));
    QQmlApplicationEngine engine;
    UiTranslator ui_trans(&engine);
    engine.rootContext()->setContextProperty("bot", bot.data());
    // Context Property UI Translator
    engine.rootContext()->setContextProperty("translate", (QObject*)&ui_trans);
    engine.rootContext()->setContextProperty("storage", (QObject*)&storage);
    engine.rootContext()->setContextProperty("fre", (QObject*)&fre_tracker);

    QScopedPointer<Logger, QScopedPointerDeleteLater> log(MOREPORK_LOGGER);
    engine.rootContext()->setContextProperty("log", log.data());

    QScopedPointer<Network, QScopedPointerDeleteLater> network(
            new Network(engine.networkAccessManager()));
    engine.rootContext()->setContextProperty("network", network.data());

    qmlRegisterType<PrintFileInfo>("PrintFileObject", 1, 0, "PrintFileInfo");
    engine.addImageProvider(QLatin1String("thumbnail"), new ThumbnailPixmapProvider);
    engine.load(MOREPORK_UI_QML_MAIN);

    QObject *rootObject = engine.rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject*>("morepork_main_qml");
    if(argc > 1 && std::string(argv[1]) == "--rotate_display_180")
        if (qmlObject)
            qmlObject->setProperty("rotation", 180);
        else
            qCritical() << "Cannot find morepork_main_qml";

    return qapp.exec();
}
