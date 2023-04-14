#ifndef POWER_KEY_EVENT_H
#define POWER_KEY_EVENT_H


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QKeyEvent>

class PowerKeyEventHandler : public QObject
{
    Q_OBJECT
signals:
    void powerbuttonPressed();
protected:
    bool eventFilter(QObject *obj, QEvent *event) override {
        if (event->type() == QEvent::KeyPress) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
            if(keyEvent->key() == 16777399) {
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
