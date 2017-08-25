#ifndef ARTIFACTS_H
#define ARTIFACTS_H

#include <QDebug>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QStringList>
#include <QVersionNumber>
#include <QDir>
#include <libarchiveqt.h>

class Artifacts : public QObject {
private:
    const QStringList REQUIRED_ARTIFACTS = QStringList{
            "MBCoreUtils",
            "Birdwing-Acceleration-Shared",
            "morepork-mbcoreutils"};

    const QString DEFAULT_SERVER
      = "http://maven.soft.makerbot.net/artifactory/";
    const QString LIST_LOC =
            DEFAULT_SERVER + "api/storage/generic-local";
    const QString SERVER_ROOT =
            DEFAULT_SERVER + "generic-local";
    enum DownloadStep {
        kInitialList,
        kBranchQuery,
        kBuildQuery,
        kBuildVersions,
        kDownloadUri,
        kDownload
    };
    struct ArtifactsListInfo {
        DownloadStep step_;
        QString curr_url_;
    };

    QNetworkAccessManager* m_network_manager_;
    QMap<QString, ArtifactsListInfo> m_artifacts_list_;

    void PrintArtifactsList();
    void MakeRequest(QString name);
    void NetworkReceived(QNetworkReply*, QString);
    QString ExtractVersionNumber(QString str);
    QString GetProperFilename(const QUrl &url);
    bool SaveFile(const QString &filename, QIODevice *data);
    bool Unzip(QString save_file_name, QString name);

    void ProcessInitialList(QJsonObject json_object);
    void ProcessBranchQuery(QJsonObject json_object, QString name);
    void ProcessBuildQuery(QJsonObject json_object, QString name);
    void ProcessBuildVersionQuery(QJsonObject json_object, QString name);
    void ProcessDownloadUriQuery(QJsonObject json_object, QString name);
    void ProcessDownloadQuery(QNetworkReply* reply, QString name);

public:
    const static QString ZIP_LOC;
    const static QString UNZIPPED_LOC;

    Artifacts();
    void GetList();
    void PullArtifacts();
}; // class Artifacts

#endif // ARTIFACTS_H
