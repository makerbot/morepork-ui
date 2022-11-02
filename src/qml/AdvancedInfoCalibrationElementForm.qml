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
        spacing: 43

        TextHeadline {
            style: TextHeadline.Base
            id: calibrationLabelProperty
            text: qsTr("CALIBRATION LABEL")
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
