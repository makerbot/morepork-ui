import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 100

    property alias calibrationLabelProperty: calibrationLabelProperty
    property alias xOffset: xOffset
    property alias yOffset: yOffset
    property alias zOffset: zOffset

    ColumnLayout {
        id: columnLayout
        spacing: 0
        anchors.fill: parent

        Text {
            id: calibrationLabelProperty
            text: qsTr("CALIBRATION LABEL")
            font.letterSpacing: 2
            font.pixelSize: 15
            font.family: defaultFont.name
            font.weight: Font.Bold
            color: "#ffffff"
        }

        Item {
            id: spacing_item
            width: 200
            height: 15
            visible: true
        }

        AdvancedInfoElement {
            id: xOffset
            label: qsTr("X OFFSET")
            value_anchors.leftMargin: 0
            value_element.width: 10
            label_width: 150
        }

        AdvancedInfoElement {
            id: yOffset
            label: qsTr("Y OFFSET")
            value_anchors.leftMargin: 0
            value_element.width: 10
            label_width: 150
        }

        AdvancedInfoElement {
            id: zOffset
            label: qsTr("Z OFFSET")
            value_anchors.leftMargin: 0
            value_element.width: 10
            label_width: 150
        }
    }
}
