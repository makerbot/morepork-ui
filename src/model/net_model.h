// Copyright 2017 Makerbot Industries

#ifndef _SRC_NET_MODEL_H
#define _SRC_NET_MODEL_H

#include <QObject>
#include <QList>

#include "base_model.h"

class WiFiAP : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY WiFiInfoChanged)
    Q_PROPERTY(bool secured READ secured NOTIFY WiFiInfoChanged)
    Q_PROPERTY(bool saved READ saved NOTIFY WiFiInfoChanged)
    Q_PROPERTY(QString path READ path NOTIFY WiFiInfoChanged)
    Q_PROPERTY(int sig_strength READ sig_strength NOTIFY WiFiInfoChanged)
    QString name_;
    bool secured_;
    bool saved_;
    QString path_;
    int sig_strength_;

public:
    WiFiAP(QObject *parent = 0) : QObject(parent) { }
    WiFiAP(const QString name = "Unknown",
           const bool secured = false,
           const bool saved = false,
           const QString path = "Unknown",
           int sig_strength = -999) :
           name_(name),
           secured_(secured),
           saved_(saved),
           path_(path),
           sig_strength_(sig_strength){ }

    QString name() const;
    bool secured() const;
    bool saved() const;
    QString path() const;
    int sig_strength() const;

signals:
    void WiFiInfoChanged();
};

class QueuedPrintInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString fileName READ fileName NOTIFY infoChanged)
    Q_PROPERTY(QString jobId READ jobId NOTIFY infoChanged)
    Q_PROPERTY(QString token READ token NOTIFY infoChanged)
    Q_PROPERTY(QString urlPrefix READ urlPrefix NOTIFY infoChanged)

    QString filename_, job_id_, token_, url_prefix_;
public:
    QueuedPrintInfo(QObject *parent = 0) : QObject(parent) {}
    QueuedPrintInfo(const QString &filename,
                    const QString &job_id,
                    const QString &token,
                    const QString &url_prefix) :
                    filename_(filename),
                    job_id_(job_id),
                    token_(token),
                    url_prefix_(url_prefix) {}

    QString fileName() const {
        return filename_;
    }

    QString jobId() const {
        return job_id_;
    }

    QString token() const {
        return token_;
    }

    QString urlPrefix() const {
        return url_prefix_;
    }

signals:
    void infoChanged();
};

class NetModel : public BaseModel {
  public:
    //MOREPORK_QML_ENUM
    enum WifiState {
         Searching,
         NoWifiFound,
         Connecting,
         Disconnecting,
         Connected,
         NotConnected
    };

    //MOREPORK_QML_ENUM
    enum WifiError {
        NoError,
        InvalidPassword,
        ConnectFailed,
        ScanFailed,
        UnknownError
    };

    Q_ENUM(WifiState)
    Q_ENUM(WifiError)

    QList<QObject*> wifi_list_;
    Q_PROPERTY(QList<QObject*> WiFiList
             READ WiFiList
             WRITE WiFiListSet
             RESET WiFiListReset
             NOTIFY WiFiListChanged)
    QList<QObject*> WiFiList() const;
    void WiFiListSet(QList<QObject*> &wifi_list);
    void WiFiListReset();
    Q_INVOKABLE void setWifiState(WifiState state);

    QList<QObject*> print_queue_;
    Q_PROPERTY(QList<QObject*> PrintQueue
             READ PrintQueue
             WRITE PrintQueueSet
             RESET PrintQueueReset
             NOTIFY PrintQueueChanged)
    QList<QObject*> PrintQueue() const;
    void PrintQueueSet(const QList<QObject*> &print_queue);
    void PrintQueueReset();

  private:
    Q_OBJECT

    MODEL_PROP(QString, ipAddr, "Unknown")
    MODEL_PROP(QString, netmask, "Unknown")
    MODEL_PROP(QString, gateway, "Unknown")
    MODEL_PROP(QString, interface, "Unknown")
    MODEL_PROP(QString, name, "Unknown")
    MODEL_PROP(QString, ethMacAddr, "Unknown")
    MODEL_PROP(QString, wlanMacAddr, "Unknown")
    MODEL_PROP(QStringList, dns, {"Unknown"})
    MODEL_PROP(bool, wifiEnabled, false)
    MODEL_PROP(WifiState, wifiState, NotConnected)
    MODEL_PROP(WifiError, wifiError, NoError)
    MODEL_PROP(bool, analyticsEnabled, false)
    MODEL_PROP(bool, printQueueEmpty, true)

  public:
    NetModel();

  signals:
    void WiFiListChanged();
    void PrintQueueChanged();
};

#endif  // _SRC_NET_MODEL_H
