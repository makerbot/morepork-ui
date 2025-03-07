import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

Item {
    height: 92
    width: 118

    property alias buttonImage: button_image.source
    property alias buttonText: button_text.text
    property alias mouseArea: action_mousearea

    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        opacity: parent.enabled ? 1 : 0.3

        Image {
            id: button_image
            height: sourceSize.height
            width: sourceSize.width
            Layout.alignment: Qt.AlignHCenter
        }

        TextSubheader {
            id: button_text
            font.letterSpacing: 3
            font.weight: Font.Medium
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 10
            leftPadding: 3
            rightPadding: 3
        }
    }

    LoggingMouseArea {
        id: action_mousearea
        logText: "PrintIcon " + buttonText + " clicked"
        smooth: false
        anchors.fill: parent
        onPressed: { parent.opacity = 0.3 }
        onReleased: { parent.opacity = 1 }
        onCanceled: { parent.opacity = 1 }
        enabled: parent.enabled
    }
}
