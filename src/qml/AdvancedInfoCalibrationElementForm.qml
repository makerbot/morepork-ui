import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 159

    property alias calibrationLabelProperty: calibrationLabelProperty
    property alias xOffset: xOffset
    property alias yOffset: yOffset
    property alias zOffset: zOffset

    ColumnLayout {
        id: columnLayout
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Base
            id: calibrationLabelProperty
            text: "CALIBRATION LABEL"
        }

        AdvancedInfoElement {
            id: xOffset
            label: qsTr("X OFFSET")
            value_element.anchors.rightMargin: 125
        }

        AdvancedInfoElement {
            id: yOffset
            label: qsTr("Y OFFSET")
            value_element.anchors.rightMargin: 125
        }

        AdvancedInfoElement {
            id: zOffset
            label: qsTr("Z OFFSET")
            value_element.anchors.rightMargin: 125
        }
    }
}
