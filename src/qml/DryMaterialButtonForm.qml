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
        spacing: 5

        TextHeadline {
            id: materialNameText
            text: "MATERIAL NAME"
            //anchors.verticalCenterOffset: -5
        }

        TextSubheader {
            id: temperatureAndTimeText
            text: "999 C | 999 HR"
            //anchors.top: materialNameText.bottom
            //anchors.topMargin: 5
            //anchors.left: parent.left
            //anchors.leftMargin: 40
            //anchors.verticalCenter: parent.verticalCenter
            font.capitalization: Font.MixedCase
        }
    }

    Image {
        id: startImage
        anchors.right: parent.right
        anchors.rightMargin: 40
    }
}
