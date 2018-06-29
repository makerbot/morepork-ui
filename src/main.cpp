// Copyright 2017 MakerBot Industries

#include <memory>

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ui_translator.h"

// TODO: We should probably be able to set this up so that
//       the qrc thing works for all builds...
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#include <QDirIterator>
#include <QFileInfo>
#include <QFontDatabase>
#include "host/host_model.h"
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/host/host_main.qml")
#define MOREPORK_BOT_MODEL makeHostBotModel()
#else
#include "model_impl/kaiten_bot_model.h"
#define MOREPORK_UI_QML_MAIN "/usr/share/morepork_ui/MoreporkUI.qml"
#define MOREPORK_BOT_MODEL makeKaitenBotModel("/tmp/kaiten.socket")
#endif
#include "parsed_qml_enums.h"
#include "storage/storage.h"

int main(int argc, char ** argv) {
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication qapp(argc, argv);

    // This includes objects of classes defined in parsed_qml_enums.h
    // so QML can use cpp defined enumerations with namespaces
    QML_ENUM_OBJECTS

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
    QDirIterator it(MOREPORK_ROOT_DIR "/fonts");
    while(it.hasNext())
        if(QFileInfo(it.next()).suffix() == "otf")
            QFontDatabase::addApplicationFont(it.fileInfo().absoluteFilePath());
#endif

    QScopedPointer<BotModel, QScopedPointerDeleteLater> bot(MOREPORK_BOT_MODEL);

    UiTranslator ui_trans;
    MoreporkStorage storage;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bot", bot.data());
    // Context Property UI Translator
    engine.rootContext()->setContextProperty("cpUiTr", (QObject*)&ui_trans);
    engine.rootContext()->setContextProperty("storage", (QObject*)&storage);
    qmlRegisterType<PrintFileInfo>("PrintFileObject", 1, 0, "PrintFileInfo");
    engine.addImageProvider(QLatin1String("thumbnail"), new ThumbnailPixmapProvider);
    engine.load(MOREPORK_UI_QML_MAIN);

    // So, basically, our UI is upside down when the one
    // is compared on the bot, to that of test in qtcreator.
    // So, that correction is done here
    // There is an update lag for the robot when performing
    // rotations from c++. Better to have the UI flipped for
    // the robot by default from qml.
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
    QObject *rootObject = engine.rootObjects().first();
    QObject *qmlObject = rootObject->findChild<QObject*>("morepork_main_qml");
    if (qmlObject)
        qmlObject->setProperty("rotation", 0);
    else
        qCritical() << "Cannot find morepork_main_qml";
#endif

    return qapp.exec();
}
