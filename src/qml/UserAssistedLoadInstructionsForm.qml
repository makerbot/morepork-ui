import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: mainItem
    width: 800
    height: 440

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
        source: "qrc:/img/user_assisted_load.png"
    }

    ColumnLayout {
        id: instructionsContainer
        height: 200
        width: 375
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            Layout.maximumWidth: parent.width
            color: "#cbcbcb"
            text: qsTr("%1 REQUIRES MANUAL ASSISTANCE TO LOAD").arg(materialName)
            wrapMode: Text.WordWrap
            font.letterSpacing: 1
            font.wordSpacing: 3
            lineHeight: 1.3
            font.family: defaultFont.name
            font.pixelSize: 22
            font.weight: Font.Bold
            antialiasing: false
            smooth: false
        }

        Text {
            id: description_text
            Layout.maximumWidth: parent.width
            color: "#cbcbcb"
            text: qsTr("Remove the lid and swivel clip. Manually " +
                       "feed the material into the filament bay slot " +
                       "until it reaches the top. Push the material " +
                       "into the extruder until you feel it begin " +
                       "pulling.")
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            lineHeight: 1.3
            antialiasing: false
            smooth: false
        }
    }
}
