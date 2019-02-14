import QtQuick 2.10

RoundedButton {
    id: roundedButton
    z: 1
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    anchors.right: parent.right
    anchors.rightMargin: 25
    buttonWidth: 76
    buttonHeight: 76
    button_rectangle.radius: buttonWidth/2
    button_rectangle.smooth: true
    button_rectangle.antialiasing: true
    button_text.visible: false
    is_button_transparent: false

    Image {
        id: refresh_image
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/refresh.png"
        width: sourceSize.width/1.6
        height: sourceSize.height/1.6
    }

    button_mouseArea.onPressed: {
        refresh_image.source = "qrc:/img/refresh_black.png"
    }

    button_mouseArea.onReleased: {
        refresh_image.source = "qrc:/img/refresh.png"
    }
}
