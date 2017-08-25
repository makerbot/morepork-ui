#include <QCoreApplication>
#include "artifacts.h"

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
    artifactory.GetList();
    return a.exec();
}
