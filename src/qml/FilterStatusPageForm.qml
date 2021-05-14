import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: filterStatusPage
    smooth: false
    visible: true
    width: 800
    height: 420

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: step_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/filter.png"
        visible: true
        cache: false
        smooth: false
    }

    ColumnLayout {
        spacing: 30
        anchors.left: step_image.right
        anchors.leftMargin: 50
        anchors.verticalCenter: step_image.verticalCenter
        anchors.verticalCenterOffset: -25

        ColumnLayout {
            spacing: 8
            Text {
                id: main_text
                color: "#ffffff"
                text: qsTr("ESTIMATED FILTER LIFETIME")
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 18
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            Text {
                id: instruction_text
                color: "#ffffff"
                text: qsTr((bot.hepaFilterMaxHours).toFixed(2)) + qsTr(" HOURS")
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.pixelSize: 16
                font.weight: Font.Light
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }
        }

        ColumnLayout {
            spacing: 8
            Text {
                id: main_text_2
                color: "#ffffff"
                text: qsTr("FILTER STATUS")
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 18
                lineHeight: 1.2
                smooth: false
                antialiasing: false

                Image {
                    id: indicator_image
                    width: sourceSize.width
                    height: sourceSize.height
                    anchors.left: parent.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -3
                    source: "qrc:/img/filter_change_required.png"
                    visible: bot.hepaFilterChangeRequired
                    cache: false
                    smooth: false
                }
            }

            Text {
                id: instruction_text_2
                color: "#ffffff"
                text: qsTr((bot.hepaFilterPrintHours).toFixed(2)) + qsTr(" HOURS")
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.pixelSize: 16
                font.weight: Font.Light
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }
        }

        ColumnLayout {
            spacing: 20
            RoundedButton {
                id: replace_filter_button
                buttonWidth: 125
                buttonHeight: 45
                label_size: 18
                label: qsTr("REPLACE FILTER")
                button_mouseArea.onClicked: {
                    cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.ReplaceFilterPage)
                }
            }

            RoundedButton {
                id: reset_filter_button
                buttonWidth: 125
                buttonHeight: 45
                label_size: 18
                label: qsTr("RESET FILTER")
                button_mouseArea.onClicked: {
                    hepaFilterResetPopup.open()
                }
            }
        }
    }

    Text {
        id: disclaimer_text
        color: "#ffffff"
        text: qsTr("Filter lifetime is dependent upon multiple factors, including but not limited to<br>materials being printed, temperatures used, and airflow.")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        font.letterSpacing: 1
        font.family: defaultFont.name
        font.pixelSize: 16
        font.weight: Font.Light
        lineHeight: 1.2
        smooth: false
        antialiasing: false
    }
}
