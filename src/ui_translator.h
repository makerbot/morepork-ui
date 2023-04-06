#ifndef __MP_TRANSLATOR__
#define __MP_TRANSLATOR__

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLocale>
#include <QDebug>

class UiTranslator : public QObject {
    Q_OBJECT
    QQmlApplicationEngine *engine_;
    QTranslator *translator_;

    public:
        UiTranslator(QQmlApplicationEngine *engine) {
            engine_ = engine;
            translator_ = new QTranslator(this);
        }

        Q_INVOKABLE void selectLanguage(QString localeStr){
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
            // desktop linux path (.qm files are placed in the executables directory)
            QString kFilePath(MOREPORK_ROOT_DIR"/src/translations/");
#else
            // embedded linux path
            QString kFilePath("/usr/share/morepork_ui/translations/");
#endif
            qApp->removeTranslator(translator_);
            // From Qt docs: locale string should be 'of the form "language_country",
            // where language is a lowercase, two-letter ISO 639 language code,
            // and country is an uppercase, two- or three-letter ISO 3166 country
            // code.'
            QString kFileName(QString("translation_%1.qm").arg(localeStr));
            QLocale::setDefault(QLocale(localeStr));

            if(translator_->load(kFilePath + kFileName)) {
                qInfo() << "Successfully loaded translation file " << kFilePath + kFileName;
                qApp->installTranslator(translator_);
                engine_->retranslate();
            } else {
                qInfo() << "error loading translation [" << kFilePath + kFileName << "]";
            }
        }
};

#endif //__MP_TRANSLATOR__
