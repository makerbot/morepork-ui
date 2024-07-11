import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: columnLayout.height
    implicitHeight: columnLayout.height

    property alias calibrationLabelProperty: calibrationLabelProperty
    property alias xOffset: xOffset
    property alias yOffset: yOffset
    property alias zOffset: zOffset

    Column {
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
        }

        AdvancedInfoElement {
            id: yOffset
            label: qsTr("Y OFFSET")
        }

        AdvancedInfoElement {
            id: zOffset
            label: qsTr("Z OFFSET")
        }
    }
}
