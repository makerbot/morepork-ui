// Copyright 2017 MakerBot Industries
#include <memory>

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>
#include <QSurfaceFormat>

#include "ui_translator.h"
#include "logger.h"
#include "logging.h"
#include "network.h"
#include "power_key_event.h"

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
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/qml/MoreporkUI.qml")
#define MOREPORK_BOT_MODEL makeKaitenBotModel("/tmp/kaiten.socket")
#define MOREPORK_LOGGER makeBotLogger()
void msgHandler(QtMsgType type,
                const QMessageLogContext & context,
                const QString &msg) {
    boost::log::trivial::severity_level level;
    switch (type) {
      case QtDebugMsg:
        level = boost::log::trivial::debug;
        break;
      case QtInfoMsg:
        level = boost::log::trivial::info;
        break;
      case QtWarningMsg:
        level = boost::log::trivial::warning;
        break;
      default:
        level = boost::log::trivial::error;
        break;
    }
    BOOST_LOG_SEV(Logging::general::get(), level) << "[ui] ["
        << (context.file?:"") << ":" << context.line << ":"
        << (context.function?:"") << "]\n" << msg.toStdString();
}
#endif
#include "fre_tracker.h"
#include "parsed_qml_enums.h"
#include "storage/storage.h"
#include "settings_interface/settings_interface.h"
#include "storage/disk_manager.h"
#include "dfs/dfs_settings.h"
#include "print_queue/print_queue.h"
#include "print_queue/asyncimageprovider.h"

int main(int argc, char ** argv) {
    /******************************************************************************/
    /***These settings must be configured before creating the application object***/
    /******************************************************************************/
    // The QML scene graph rendering can run in two modes -- threaded or basic.
    // The default mode is threaded where a separate thread named QMLSceneGraph
    // provides better performance on multicore processors. Basic mode renders
    // the scene graph within the main program thread. Running the UI in basic
    // mode reduces the frame rate to around 60fps (slightly oveshooting to 62
    // at times) from 67fps in threaded mode. But more importantly this also
    // reduced the CPU usage by 30% along with the frame rate becoming more
    // consistent.
    // https://doc.qt.io/qt-5/qtquick-visualcanvas-scenegraph.html#scene-graph-and-rendering
    qputenv("QSG_RENDER_LOOP", "basic");
    // QSurfaceFormat -- https://doc.qt.io/qt-5/qsurfaceformat.html
    QSurfaceFormat format = QSurfaceFormat::defaultFormat();
    // This should enable vsync but will be silently ignored if the underlying
    // platform isn't configured to support it which is the case here I think.
    // But it doesnt hurt to leave it on, whenever vsync is enabled at the OS
    // level this should pick it up.
    format.setSwapInterval(1);
    format.setSwapBehavior(QSurfaceFormat::TripleBuffer);
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    QSurfaceFormat::setDefaultFormat(format);
    /******************************************************************************/

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
    SettingsInterface settings;
    DiskManager disk_manager;
    DFSSettings dfs_settings;
    PowerKeyEventHandler power_key;

    QLocale::setDefault(QLocale(settings.getLanguageCode()));

    QQmlApplicationEngine engine;
    UiTranslator ui_trans(&engine);
    ui_trans.selectLanguage(settings.getLanguageCode());
    engine.rootContext()->setContextProperty("bot", bot.data());
    // Context Property UI Translator
    engine.rootContext()->setContextProperty("translate", (QObject*)&ui_trans);
    engine.rootContext()->setContextProperty("power_key", (QObject*)&power_key);
    engine.rootContext()->setContextProperty("storage", (QObject*)&storage);
    engine.rootContext()->setContextProperty("fre", (QObject*)&fre_tracker);
    engine.rootContext()->setContextProperty("settings", (QObject*)&settings);
    engine.rootContext()->setContextProperty("diskman", (QObject*)&disk_manager);
    engine.rootContext()->setContextProperty("dfs", (QObject*)&dfs_settings);

    QScopedPointer<Logger, QScopedPointerDeleteLater> log(MOREPORK_LOGGER);
    engine.rootContext()->setContextProperty("log", log.data());

    QScopedPointer<Network, QScopedPointerDeleteLater> network(
            new Network(engine.networkAccessManager()));
    engine.rootContext()->setContextProperty("network", network.data());

    PrintQueue print_queue(engine.networkAccessManager());
    engine.rootContext()->setContextProperty("print_queue", (QObject*)&print_queue);

    qmlRegisterType<PrintFileInfo>("PrintFileObject", 1, 0, "PrintFileInfo");
    engine.addImageProvider(QLatin1String("thumbnail"), new ThumbnailPixmapProvider);
    engine.addImageProvider(QLatin1String("async"), new AsyncImageProvider);

    engine.load(MOREPORK_UI_QML_MAIN);

    QList<QObject *> rootObjects = engine.rootObjects();
    if (rootObjects.empty()) {
        qCritical() << "Failed to find any root objects (QML parse error?)";
        return -1;
    }

    QObject *rootObject = rootObjects.first();
    QObject *qmlObject = rootObject->findChild<QObject*>("morepork_main_qml");
    if(argc > 1 && std::string(argv[1]) == "--rotate_display_180") {
        if (qmlObject) {
            qmlObject->setProperty("rotation", 180);
        } else {
            qCritical() << "Cannot find morepork_main_qml";
        }
    }
    qapp.installEventFilter((QObject*) &power_key);
    return qapp.exec();
}
