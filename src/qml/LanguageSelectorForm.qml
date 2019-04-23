import QtQml 2.8
import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: itemSelectLanguage
    smooth: false
    anchors.fill: parent

    property string currentLocale

    Flickable {
        id: flickableSelectLanguage
        smooth: false
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.fill: parent
        contentHeight: columnSelectLanguage.height

        Column {
            id: columnSelectLanguage
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            LanguageButton {
                id: buttonLanguageArabic
                languageName: "عربى"
                localeCode: "ar_EG"
            }

            LanguageButton {
                id: buttonLanguageChinese
                languageName: "中文"
                localeCode: "zh_CN"
            }

            LanguageButton {
                id: buttonLanguageEnglish
                languageName: "ENGLISH"
                localeCode: "en_GB"
            }

            LanguageButton {
                id: buttonLanguageFrench
                languageName: "FRANÇAIS"
                localeCode: "fr_FR"
            }

            LanguageButton {
                id: buttonLanguageGerman
                languageName: "DEUTSCHE"
                localeCode: "de_DE"
            }

            LanguageButton {
                id: buttonLanguageItalian
                languageName: "ITALIANO"
                localeCode: "it_IT"
            }

            LanguageButton {
                id: buttonLanguageJapanese
                languageName: "日本人"
                localeCode: "ja_JP"
            }

            LanguageButton {
                id: buttonLanguageKorean
                languageName: "한국어"
                localeCode: "ko_KR"
            }

            LanguageButton {
                id: buttonLanguageRussian
                languageName: "РУССКИЙ"
                localeCode: "ru_RU"
            }

            LanguageButton {
                id: buttonLanguageSpanish
                languageName: "ESPAÑOL"
                localeCode: "es_ES"
            }
        }
    }
}
