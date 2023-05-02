import QtQuick 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    property var steps: []
    property var activeSteps : []
    property int stepBegin: 1
    property int usedTextWidth: parent.width
    spacing: 24

    Repeater {
        id: repeater
        model: steps

        RowLayout {
            spacing: 12
            Layout.preferredWidth: parent.width
            opacity: activeSteps[index] ? 1 : 0.3

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
                Layout.alignment: Text.AlignLeft
                Layout.preferredWidth: usedTextWidth
            }
        }
    }
}
