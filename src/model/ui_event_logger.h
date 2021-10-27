#ifndef UI_EVENT_LOGGING_H
#define UI_EVENT_LOGGING_H

#include "logging.h"
#include <QObject>
#include <QtGui>
#include <QtQml>

class UiEventLogger : public QObject
{
    Q_OBJECT

public:
    static QObject *GetInstance(QQmlEngine* engine, QJSEngine* sengine);

    Q_INVOKABLE void beginUiEventLogging(QObject *object);
    bool eventFilter(QObject *obj, QEvent *event);

    UiEventLogger(UiEventLogger const&) = delete;
    void operator=(UiEventLogger const&) = delete;

private:
    UiEventLogger();
};

#endif

