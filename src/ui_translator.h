#ifndef __MP_TRANSLATOR__
#define __MP_TRANSLATOR__

#include <QGuiApplication>
#include <QTranslator>
#include <QDebug>

class UiTranslator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString emptyStr READ getEmptyStr NOTIFY languageChanged)
    QTranslator *translator_;

    public:
        UiTranslator() {
            translator_ = new QTranslator(this);
        }

        QString getEmptyStr() {
            return QString();
        }

        Q_INVOKABLE void selectLanguage(QString trans_file_suffix){
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
            // desktop linux path (.qm files are placed in the executables directory)
            QString kFilePath(MOREPORK_ROOT_DIR"/src/translations/");
#else
            // embedded linux path
            QString kFilePath("/usr/share/morepork_ui/translations/");
#endif
            // .qm files are generated from .ts files during compilation
            // load the .qm file by referenceing it without the .qm extension
            QString kFileNameNoExt(QString("morepork_%1.ts").arg(trans_file_suffix));
            if(!translator_->load(kFilePath + kFileNameNoExt)) {
                qInfo() << "error loading translation [" << kFilePath << kFileNameNoExt << "]\n";
            } else {
                qInfo() << "Successfully loaded translation file " << kFilePath << kFileNameNoExt;
            }
            qApp->installTranslator(translator_);
            emit languageChanged();
        }

    signals:
        void languageChanged();
};

#endif //__MP_TRANSLATOR__
