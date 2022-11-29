import QtQml 2.8
import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9

Item {
    id: itemSelectLanguage
    smooth: false
    anchors.fill: parent

    property string currentLocale
    property variant supportedLanguages: [
        {eng_name: "Arabic", name: "عربى", localeCode: "ar_EG"},
        {eng_name: "Chinese", name: "中文（简体）", localeCode: "zh_CN"},
        {eng_name: "English", name: "ENGLISH", localeCode: "en_GB"},
        {eng_name: "French", name: "FRANÇAIS", localeCode: "fr_FR"},
        {eng_name: "German", name: "DEUTSCHE", localeCode: "de_DE"},
        {eng_name: "Italian", name: "ITALIANO", localeCode: "it_IT"},
        {eng_name: "Japanese", name: "日本語", localeCode: "ja_JP"},
        {eng_name: "Korean", name: "한국어", localeCode: "ko_KR"},
        {eng_name: "Russian", name: "РУССКИЙ", localeCode: "ru_RU"},
        {eng_name: "Spanish", name: "ESPAÑOL", localeCode: "es_ES"}
    ]

    ListSelector {
        id: languageSelector
        model: supportedLanguages
        delegate:
            MenuButton {
                id: languageButton
                property string localeCode: model.modelData["localeCode"]
                enabled: !(currentLocale == localeCode)
                buttonImage {
                    source: "qrc:/img/selected_checkmark.png"
                    visible: currentLocale == localeCode
                }
                buttonText.text: model.modelData["name"]

                onClicked: {
                    languageChangeInProgressPopup.open()
                    delayedSetLanguage.start()
                }

                Timer {
                    id: delayedSetLanguage
                    interval: 1000
                    onTriggered: {
                        translate.selectLanguage(languageButton.localeCode)
                        settings.setLanguageCode(languageButton.localeCode)

                        // The locale name can only be accessed from
                        // the constructed object
                        currentLocale = Qt.locale().name
                        languageChangeInProgressPopup.close()
                    }
                }
            }
    }

    CustomPopup {
        popupName: "LanguageChangeInProgress"
        id: languageChangeInProgressPopup
        showOneButton: false
        showTwoButtons: false

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            BusySpinner {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextHeadline {
                text: qsTr("PLEASE WAIT")
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}
