import QtQuick 2.5
import QtQuick.Controls 2.0

Rectangle {
    width: 440
    height: 800

    TabBar {
        id: bar
        width: parent.width
        TabButton { text: "/" }
        TabButton { text: "/net" }
        TabButton { text: "/process" }
        TabButton { text: "language" }
    }

    SwipeView {
        y: bar.height
        width: parent.width
        currentIndex: bar.currentIndex
        Item { PropsView { bot_model: bot } }
        Item { PropsView { bot_model: bot.net } }
        Item { PropsView { bot_model: bot.process } }
        Item {
            Row {
                spacing: 10
                Label {
                    id: languageCodeLabel
                    text: "language code: "
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }

                TextField {
                    property string language: settings.getLanguageCode()
                    text: language
                    onEditingFinished: {
                        language = text;
                        translate.selectLanguage(text);
                    }
                }
            }
        }
    }

}
