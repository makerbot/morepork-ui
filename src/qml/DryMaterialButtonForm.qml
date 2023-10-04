import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9

Button {
    id: selectMaterialButton
    width: parent.width
    height: 80
    smooth: false
    property alias materialNameText: materialNameText.text
    property alias temperatureAndTimeText: temperatureAndTimeText.text
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: selectMaterialButton.down ? 1 : 0
        color: selectMaterialButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
        anchors.topMargin: 0
        smooth: false
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        TextHeadline {
            id: materialNameText
            text: "MATERIAL NAME"
        }

        TextSubheader {
            id: temperatureAndTimeText
            text: "999 C | 999 HR"
            font.capitalization: Font.MixedCase
            opacity: 0.8
        }
    }

    Image {
        id: startImage
        width: sourceSize.width
        height: sourceSize.height
        anchors.right: parent.right
        anchors.rightMargin: 40
        smooth: false
        antialiasing: false
        source: "qrc:/img/icon_start.png"
        anchors.verticalCenter: parent.verticalCenter
        visible: true
    }
}
