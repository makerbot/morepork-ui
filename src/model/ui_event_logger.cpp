#include "ui_event_logger.h"
#include <QObject>
#include <QtGui>
#include <QtQml>

QObject *UiEventLogger::GetInstance(QQmlEngine* engine, QJSEngine* sengine) {
    // Q_UNUSED(engine)
    // Q_UNUSED(sengine)

    static UiEventLogger instance;
    return &instance;
}

void UiEventLogger::beginUiEventLogging(QObject *obj) {
    if (!obj)
        return;
    obj->installEventFilter(this);
    qInfo() << "UIEVENTLOGGER begin for [" << obj << "]";
}

bool UiEventLogger::eventFilter(QObject *obj, QEvent *event) {
    // todo(william): make this toggleable to avoid spamming the logs
    if(1) {
        qInfo() << "UIEVENTLOGGER";
        switch(event->type()) {
            case QEvent::MouseButtonPress: {
                QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
                qInfo() << "Mouse Press Event: [" << obj << "] got [" <<
                    mouseEvent->globalX() << "," <<
                    mouseEvent->globalY() << "]";
                break;
            }
            default: {
                qInfo() << "Unknown event type: [" << obj << "] got [" <<
                    event->type() << "]";
            }
        }
    }

    /* always return false to ensure the appropriate underlying UI
     * entity eventually recieves UI events
     */
    return false;
}

// UiEventLogger::UiEventLogger(QObject *parent = nullptr) : QObject(parent) {}
UiEventLogger::UiEventLogger() {}
