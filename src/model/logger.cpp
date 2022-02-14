// Copyright 2017 Makerbot Industries
#include <QMetaEnum>
#include "logger.h"

Logger::Logger() {
}

void Logger::info(QString msg) {
    qInfo() << msg;
}

QString Logger::getEnumName(QObject *object, QString name, int index) const {
    const QMetaObject* meta = object->metaObject();
    int indexOfEnum = meta->indexOfEnumerator(&name.toStdString()[0]);
    if(indexOfEnum == -1) {
        qInfo() << "Enum not found; Check the itemWithEnum attribute for this swipeview";
        return QString(index);
    }
    QMetaEnum e = meta->enumerator(indexOfEnum);
    return QString(e.valueToKey(index));
}

class DummyLogger : public Logger {
  public:
    DummyLogger() {
    }
};

Logger * makeLogger() {
    return dynamic_cast<Logger*>(new DummyLogger());
}
