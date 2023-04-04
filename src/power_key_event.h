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
            if(keyEvent->key() == 16777399) {
                qInfo() << "Registered power button event, emitting to QML";
                emit powerbuttonPressed();
                return true;
            }
            return QObject::eventFilter(obj, event);
        } else {
            // standard event processing
            return QObject::eventFilter(obj, event);
        }
    }
};


#endif // POWER_KEY_EVENT_H
