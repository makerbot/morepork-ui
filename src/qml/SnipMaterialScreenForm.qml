import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: mainItem
    width: 800
    height: 440

    property alias continueButton: continueButton

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/cut_filament_tip.png"
    }

    ColumnLayout {
        id: instructionsContainer
        height: 240
        anchors.left: image.right
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            color: "#cbcbcb"
            text: qsTr("REMOVE BENT MATERIAL")
            font.letterSpacing: 1
            font.wordSpacing: 3
            font.family: "Antenna"
            font.pixelSize: 22
            font.weight: Font.Bold
            antialiasing: false
            smooth: false
        }

        Text {
            id: description_text
            color: "#cbcbcb"
            text: qsTr("Cleanly cut any material that is bent\nor kinked before inserting it into the\nguide tube. Any kinks can cause the\nmaterial to become jammed in the\ntube.")
            font.family: "Antenna"
            font.pixelSize: 20
            font.weight: Font.Light
            lineHeight: 1.3
            antialiasing: false
            smooth: false
        }

        RoundedButton {
            id: continueButton
            buttonWidth: 200
            buttonHeight: 50
            label_width: 200
            label_size: 20
            label: qsTr("CONTINUE")
        }
    }
}
