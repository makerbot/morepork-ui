#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char ** argv)
{
    QGuiApplication qapp(argc, argv);

    // TODO: Find the qml file in a way that works for qt creator builds
    QQmlApplicationEngine engine("/usr/share/morepork_ui/main.qml");

    return qapp.exec();
}
