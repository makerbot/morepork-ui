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

    TextField {
        id: filter_input
        y: bar.height
        width: parent.width
        height: 50
    }

    SwipeView {
        y: bar.height + filter_input.height
        width: parent.width
        currentIndex: bar.currentIndex
        Item {
            PropsView {
                bot_model: bot
                filter: filter_input.text
            }
        }
        Item {
            PropsView {
                bot_model: bot.net
                filter: filter_input.text
            }
        }
        Item {
            PropsView {
                bot_model: bot.process
                filter: filter_input.text
            }
        }
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
