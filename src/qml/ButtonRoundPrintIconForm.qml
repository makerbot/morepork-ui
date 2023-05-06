import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

ColumnLayout {
    height: children.height
    width: 118
    spacing: 15

    property alias buttonImage: button_image.source
    property alias buttonText: button_text.text
    property alias mouseArea: action_mousearea

    Image {
        id: button_image
        height: sourceSize.height
        width: sourceSize.width
        Layout.alignment: Qt.AlignHCenter
    }

    TextSubheader {
        id: button_text
        Layout.preferredWidth: parent.width
        Layout.alignment: Qt.AlignHCenter
    }

    LoggingMouseArea {
        id: action_mousearea
        logText: "PrintIcon " + buttonText + " clicked"
        smooth: false
        anchors.fill: parent
        onPressed: { parent.opacity = 0.3 }
        onReleased: { parent.opacity = 1 }
        onCanceled: { parent.opacity = 1 }
    }
}
