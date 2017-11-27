#include "artifacts.h"
#include <cassert>
#include <QDirIterator>
const QString Artifacts::PROJECT_DIR = PROJECT_SOURCE_DIR;
const QString Artifacts::ZIP_LOC      = PROJECT_DIR + "/artifacts/";
const QString Artifacts::UNZIPPED_LOC = PROJECT_DIR + "/../artifacts/";

Artifacts::Artifacts(){
    qDebug() << "Initialized artifactory";
    finished_count = 0;
    m_network_manager_ = new QNetworkAccessManager(this);
}

void Artifacts::GetList() {
    ArtifactsListInfo info = {kInitialList, LIST_LOC};
    MakeRequest("Initiate");
}

void Artifacts::MakeRequest(QString name) {
    QString url;
    if (name == "Initiate") url = LIST_LOC;
    else url = m_artifacts_list_[name].curr_url_;
    QNetworkRequest request((QUrl(url)));
    QNetworkReply* reply = m_network_manager_->get(request);
    connect(reply, &QNetworkReply::finished, this,
        [this, name, reply]() {
            NetworkReceived(reply, name);
    });
    m_network_manager_->get(QNetworkRequest(QUrl(url)));
}

void Artifacts::PrintArtifactsList() {
    for(auto e : m_artifacts_list_.keys()) {
      qInfo() << e << "," << m_artifacts_list_.value(e).step_ << ", "
              << m_artifacts_list_.value(e).curr_url_ << '\n';
    }
}

void Artifacts::NetworkReceived(QNetworkReply * reply, QString name) {
    qDebug() << name << " asked with url: "
             << m_artifacts_list_[name].curr_url_;
    DownloadStep current_step = m_artifacts_list_[name].step_;
    if (current_step == kDownload) {
        ProcessDownloadQuery(reply, name);
        return;
    }

    QByteArray data = reply->readAll();
    QJsonObject json_object = QJsonDocument::fromJson(data).object();
    switch (current_step) {
        case kInitialList:
            ProcessInitialList(json_object);
            break;
        case kBranchQuery:
            ProcessBranchQuery(json_object, name);
            break;
        case kBuildQuery:
            ProcessBuildQuery(json_object, name);
            break;
        case kBuildVersions:
            ProcessBuildVersionQuery(json_object, name);
            break;
        case kDownloadUri:
            ProcessDownloadUriQuery(json_object, name);
            break;
        default:
            break;
    }
}

void Artifacts::ProcessInitialList(QJsonObject json_object) {
    QJsonArray children = json_object["children"].toArray();
    foreach (const QJsonValue &element, children) {
        QJsonObject obj = element.toObject();
        QString name = obj["uri"].toString().replace("/", "");
        if (REQUIRED_ARTIFACTS.contains(name)) {
            QString new_url = LIST_LOC+obj["uri"].toString();
            ArtifactsListInfo artifacts_info = {kBranchQuery, new_url};
            m_artifacts_list_.insert(name, artifacts_info);
            MakeRequest(name);
        }
    }
    PrintArtifactsList();
}

void Artifacts::ProcessBranchQuery(QJsonObject json_object, QString name) {
    QJsonArray children = json_object["children"].toArray();
    // Can go through all the branches here to find the one to work with,
    // But for now just gonna use develop

    bool has_seeking_branch = false;
    QString curr_branch = "";
    foreach (const QJsonValue &element, children) {
        QJsonObject obj = element.toObject();
        curr_branch = obj["uri"].toString();
        if (curr_branch == "/develop") {
            has_seeking_branch = true;
            break;
        }
    }
    if (has_seeking_branch) {
        QString new_url = m_artifacts_list_[name].curr_url_+curr_branch;
        ArtifactsListInfo artifacts_info = {kBuildQuery, new_url};
        m_artifacts_list_.insert(name, artifacts_info);
        MakeRequest(name);
    } else {
        qInfo() << name << " does not have seeking branch to pull down from.";
        SetDone(name);
    }
}

void Artifacts::ProcessBuildQuery(QJsonObject json_object, QString name) {
    QJsonArray children = json_object["children"].toArray();
    // Can go through all the builds here to find the one to work with,
    // But for now just gonna use Ubuntu_1604_64

    bool has_seeking_build = false;
    QString curr_build = "";
    foreach (const QJsonValue &element, children) {
        QJsonObject obj = element.toObject();
        curr_build = obj["uri"].toString();
        if (curr_build == "/Ubuntu_1604_64") {
            has_seeking_build = true;
            break;
        }
    }
    if (has_seeking_build) {
        QString new_url = m_artifacts_list_[name].curr_url_+curr_build;
        ArtifactsListInfo artifacts_info = {kBuildVersions, new_url};
        m_artifacts_list_.insert(name, artifacts_info);
        MakeRequest(name);
    } else {
        qInfo() << name << " does not have seeking build to pull down from.";
        SetDone(name);
    }
}

void Artifacts::ProcessBuildVersionQuery(
        QJsonObject json_object, QString name) {
    QJsonArray children = json_object["children"].toArray();

    bool has_stable_build = false;
    QString curr_build = "";
    QVersionNumber latest_version = QVersionNumber::fromString("0.0.0.0");
    foreach (const QJsonValue &element, children) {
        QJsonObject obj = element.toObject();
        curr_build = obj["uri"].toString();
        if (curr_build.indexOf("-stable") >= 0) {
            has_stable_build = true;
            QString curr_version_str = ExtractVersionNumber(curr_build);
            QVersionNumber curr_version =
                    QVersionNumber::fromString(curr_version_str);
            if (QVersionNumber::compare(curr_version, latest_version)) {
                latest_version = curr_version;
            }
        }
    }
    if (has_stable_build) {
        QString new_url = m_artifacts_list_[name].curr_url_+curr_build;
        ArtifactsListInfo artifacts_info = {kDownloadUri, new_url};
        m_artifacts_list_.insert(name, artifacts_info);
        MakeRequest(name);
    } else {
        qInfo() << name << " does not have seeking build to pull down from.";
        SetDone(name);
    }
}

void Artifacts::ProcessDownloadUriQuery(
        QJsonObject json_object, QString name) {
    if (json_object.contains("downloadUri")) {
        QString download_uri = json_object["downloadUri"].toString();
        ArtifactsListInfo artifacts_info = {kDownload, download_uri};
        m_artifacts_list_.insert(name, artifacts_info);
        MakeRequest(name);
    } else {
        qWarning() << name << " does not have downloadUri Key in given build";
        SetDone(name);
    }
}

void Artifacts::ProcessDownloadQuery(QNetworkReply* reply, QString name) {
    QString save_file_name = ZIP_LOC+GetProperFilename(
                reply->url());
    if (SaveFile(save_file_name, reply)) {
        qInfo() << "Successfully saved file " << save_file_name;
        assert(Unzip(save_file_name, name));
        qInfo() << "Unzip successful.";
        SetDone(name);
    }
    if (IsAllDone()) {
        qInfo() << "All complete!!!";
        MergeUsr();
        Artifacts::AllDone();
    }
}

// Note:: Might have to change to dynamic branch in the future
// Currently only works with develop branch
QString Artifacts::ExtractVersionNumber(QString str) {
    QStringList name_parts = str.split("-");
    QString version = "";
    for (int i = 0; i < name_parts.size(); i++) {
        if (name_parts[i] == "develop") {
            version = name_parts[i+1];
            break;
        }
    }
    return version;
}

QString Artifacts::GetProperFilename(const QUrl &file_url) {
    QString path = file_url.path();
    QString basename = QFileInfo(path).fileName();
    if (basename.isEmpty()) basename = "file";
    return basename;
}

bool Artifacts::SaveFile(const QString &filename, QIODevice *data) {
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        fprintf(stderr, "Could not open %s for writing: %s\n",
                qPrintable(filename),
                qPrintable(file.errorString()));
        return false;
    }
    file.write(data->readAll());
    file.close();
    return true;
}

bool Artifacts::Unzip(QString zipped_file_name, QString name) {
    QString unzip_loc = UNZIPPED_LOC+name;
    if (!QDir(unzip_loc).exists()) {
        QDir().mkdir(unzip_loc);
    }
    QProcess decompressor;
    QString cmd = "tar -jxf " + zipped_file_name +
                  " --directory " + unzip_loc;
    qInfo() << cmd;
    decompressor.setProcessChannelMode(QProcess::MergedChannels);
    decompressor.start(cmd);
    decompressor.waitForFinished();
    // Continue reading the data until EOF reached
    if (decompressor.exitStatus() != QProcess::NormalExit){
      QByteArray output_data;
      output_data.append(decompressor.readAllStandardOutput());
      qDebug() << output_data.data();

      qDebug("Error: ");
      QByteArray error_data;
      error_data.append(decompressor.readAllStandardError());
      qDebug() << error_data.data();
      qDebug("Done!");
      decompressor.close();
      return false;
    }
    decompressor.close();
    return true;
}

void Artifacts::SetDone(QString name) {
    ArtifactsListInfo artifacts_info = {kDone, ""};
    m_artifacts_list_.insert(name, artifacts_info);
    finished_count++;
    qInfo() << "Done with " << name;

}

bool Artifacts::IsAllDone() {
    return ((GetTotalArtifacts() - finished_count) <= 0);
}

size_t Artifacts::GetTotalArtifacts() {
    return m_artifacts_list_.size() - 1; // 1 being the initial placeholder
}

void MergeSubDir(const QString &sub_dir_path, const QString &dst_dir_path) {
    if(QFileInfo(sub_dir_path).exists()){
        QDirIterator it1(sub_dir_path);
        while(it1.hasNext()){
            QFileInfo file_info1 = it1.next();
            QDir dir;
            dir.rename(file_info1.absoluteFilePath(), dst_dir_path + "/"
                + file_info1.fileName());
        }
    }
}

void Artifacts::MergeUsr() {
#ifdef __linux__
    const QString include_rel_path = "usr/include",
                  lib_rel_path = "usr/lib",
                  bin_rel_path = "usr/bin",
                  cmake_rel_path = "cmake";
    const QString include_abs_path = UNZIPPED_LOC+include_rel_path,
                  lib_abs_path = UNZIPPED_LOC+lib_rel_path,
                  bin_abs_path = UNZIPPED_LOC+bin_rel_path,
                  cmake_abs_path = UNZIPPED_LOC+cmake_rel_path;
    QDir().mkpath(include_abs_path);
    QDir().mkpath(lib_abs_path);
    QDir().mkpath(bin_abs_path);
    QDir().mkpath(cmake_abs_path);

    QDirIterator it0(UNZIPPED_LOC);
    // iterate through UNZIPPED_LOC which should contain untar'd artifacts
    // like 'libtinything' and 'MBCoreUtils'. they typically contain a 'usr'
    // and 'cmake' directory.
    QString sub_dir_path;
    while(it0.hasNext()){
        QFileInfo file_info0 = it0.next();
        if(file_info0.isDir() && file_info0.fileName() != "usr"){
            sub_dir_path = file_info0.absoluteFilePath()+"/"+include_rel_path;
            MergeSubDir(sub_dir_path, include_abs_path);
            sub_dir_path = file_info0.absoluteFilePath()+"/"+lib_rel_path;
            MergeSubDir(sub_dir_path, lib_abs_path);
            sub_dir_path = file_info0.absoluteFilePath()+"/"+bin_rel_path;
            MergeSubDir(sub_dir_path, bin_abs_path);
            sub_dir_path = file_info0.absoluteFilePath()+"/"+cmake_rel_path;
            MergeSubDir(sub_dir_path, cmake_abs_path);
        }
    }
#endif
}

