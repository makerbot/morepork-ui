#ifndef __MP_TRANSLATOR__
#define __MP_TRANSLATOR__

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QDebug>

class UiTranslator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString emptyStr READ getEmptyStr NOTIFY languageChanged)
    QQmlApplicationEngine *engine_;
    QTranslator *translator_;

    public:
        UiTranslator(QQmlApplicationEngine *engine) {
            engine_ = engine;
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
            qApp->removeTranslator(translator_);
            // .qm files are generated from .ts files during compilation
            // load the .qm file by referenceing it without the .qm extension
            QString kFileNameNoExt(QString("morepork_%1.qm").arg(trans_file_suffix));
            if(translator_->load(kFilePath + kFileNameNoExt)) {
                qInfo() << "Successfully loaded translation file " << kFilePath + kFileNameNoExt;
                qApp->installTranslator(translator_);
                engine_->retranslate();
                emit languageChanged();
            } else {
                qInfo() << "error loading translation [" << kFilePath + kFileNameNoExt << "]\n";
            }
        }

    signals:
        void languageChanged();
};

#endif //__MP_TRANSLATOR__
