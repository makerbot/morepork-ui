#ifndef POWER_KEY_EVENT_H
#define POWER_KEY_EVENT_H


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QKeyEvent>

class KeyPressEater : public QObject
{
    Q_OBJECT
public:
    KeyPressEater(){}

signals:
    void powerbuttonPressed();
protected:
    bool eventFilter(QObject *obj, QEvent *event) override {
        if (event->type() == QEvent::KeyPress) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
            qInfo() << "Ate key press" << keyEvent->key();
            emit powerbuttonPressed();
            return true;
        } else {
            // standard event processing
            return QObject::eventFilter(obj, event);
        }
    }
};


#endif // POWER_KEY_EVENT_H
