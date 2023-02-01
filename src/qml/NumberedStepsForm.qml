import QtQuick 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    property var steps: []
    property int stepBegin: 1
    spacing: 24

    Repeater {
        id: repeater
        model: steps

        RowLayout {
            spacing: 12

            Rectangle {
                id: numberCircle
                width: 24
                height: 24
                radius: 12
                color: "#ffffff"

                TextSubheader {
                    id: stepNumber
                    style: TextSubheader.Bold
                    text: index + stepBegin
                    color: "#000000"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 3
                }
            }

            TextBody {
                id: stepText
                style: TextBody.Base
                width: parent.width
                text: modelData
                font.weight: Font.Normal
            }
        }
    }
}
