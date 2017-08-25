#include <QCoreApplication>
#include <QTimer>

#include "artifacts.h"

void exit() {
    qInfo() << "Finished!";
}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    if (!QDir(Artifacts::ZIP_LOC).exists()) {
        QDir().mkdir(Artifacts::ZIP_LOC);
    }
    qDebug() << "Curr dir: " << QDir::currentPath();
    if (!QDir(Artifacts::UNZIPPED_LOC).exists()) {
        QDir().mkdir(Artifacts::UNZIPPED_LOC);
    }
    Artifacts artifactory;

    QObject::connect(&artifactory, SIGNAL(AllDone()), &a, SLOT(quit()));
    // This will run the task from the application event loop.
    QTimer::singleShot(0, &artifactory, SLOT(GetList()));

    return a.exec();
}
