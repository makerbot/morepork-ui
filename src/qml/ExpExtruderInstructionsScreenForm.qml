import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: mainItem
    width: 800
    height: 440

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/exp_extruder_instructions.png"
    }

    ColumnLayout {
        id: instructionsContainer
        height: 200
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            color: "#cbcbcb"
            text: qsTr("FEED MATERIAL THROUGH\nAUX PORT 1")
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
            color: "#cbcbcb"
            text: qsTr("Remove the cover on the top left of the\n" +
                       "printer and feed material into AUX port\n" +
                       "1. Keep feeding until you feel it pulled\n" +
                       "in by the extruder.")
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            lineHeight: 1.3
            antialiasing: false
            smooth: false
        }
    }
}
