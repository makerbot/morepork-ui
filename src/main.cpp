#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

// TODO: We should probably be able to set this up so that
//       the qrc thing works for all builds...
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#define MOREPORK_UI_QML_MAIN QUrl("qrc:/main.qml")
#else
#define MOREPORK_UI_QML_MAIN "/usr/share/morepork_ui/main.qml"
#endif

int main(int argc, char ** argv)
{
    QGuiApplication qapp(argc, argv);

    QQmlApplicationEngine engine(MOREPORK_UI_QML_MAIN);

    engine.rootContext()->setContextProperty("botIpAddr", "10.1.23.45");

    return qapp.exec();
}
