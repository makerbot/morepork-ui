import QtQuick 2.10

Item {
    id: item1
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: update_successful_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 65
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/process_successful.png"
        visible: true
    }

    Item {
        id: containerItem
        width: 400
        height: 200
        anchors.verticalCenterOffset: -10
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            color: "#ffffff"
            text: qsTr("FIRMWARE %1\nSUCCESSFULLY\nINSTALLED").arg(bot.version)
            font.letterSpacing: 2
            anchors.top: parent.top
            anchors.topMargin: 35
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 22
            lineHeight: 1.3
        }

        RoundedButton {
            id: continueButton
            anchors.top: title_text.bottom
            anchors.topMargin: 30
            label_width: 175
            buttonWidth: 175
            label: qsTr("CONTINUE")
            buttonHeight: 50
            button_mouseArea.onClicked: {
                fre.acknowledgeFirstBoot()
            }
        }
    }
}
