import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Popup {
    property alias popup: popup
    property alias left_text: left_text
    property alias left_mouseArea: left_mouseArea
    property alias right_text: right_text
    property alias right_mouseArea: right_mouseArea
    property alias full_button_text: full_button_text
    property alias full_button_mouseArea: full_button_mouseArea
    property alias popup_contents: popup_contents

    property bool showButtonBar: false
    property bool showTwoButtons: false
    property bool disableUserClose: false

    id: popup
    modal: true
    dim: false
    focus: true
    width: 720
    height: showButtonBar ? 320 : 275
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: overlay

    // manual dim; there's probably a better way to handle this
    background: Rectangle {
        opacity: 0.5
        color: "#000000"
        width: 800
        height: 480
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
    }

    closePolicy: disableUserClose ? Popup.NoAutoClose : Popup.CloseOnPressOutside
    enter: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
    }
    exit: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
    }

    onClosed: {
        showButtonBar = false;
        showTwoButtons = false;
        left_text.text = "";
        right_text.text = "";
        full_button_text.text = "";
        // TODO: other resetting things
    }

    Rectangle {
        id: basePopupItem
        color: "#000000"
        rotation: rootItem.rotation == 180 ? 180 : 0
        width: popup.width
        height: popup.height
        radius: 10
        border.width: 2
        border.color: "#ffffff"
        y: topBar.barHeight  // TODO: check this
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: horizontal_divider
            width: 720
            height: 2
            color: "#ffffff"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 72
            visible: showButtonBar
        }

        Rectangle {
            id: vertical_divider
            x: 359
            y: 328
            width: 2
            height: 72
            color: "#ffffff"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            visible: showTwoButtons
        }

        Item {
            id: buttonBar
            width: 720
            height: 72
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            visible: showButtonBar

            Rectangle {
                id: left_rectangle
                x: 0
                y: 0
                width: 360
                height: 72
                color: "#00000000"
                radius: 10
                visible: showTwoButtons

                Text {
                    id: left_text
                    color: "#ffffff"
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: false
                    font.letterSpacing: 3
                    font.weight: Font.Bold
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    id: left_mouseArea
                    anchors.fill: parent
                    onPressed: {
                        left_rectangle.color = "#ffffff"
                        left_text.color = "#000000"
                    }
                    onReleased: {
                        left_rectangle.color = "#00000000"
                        left_text.color = "#ffffff"
                    }
                }
            }

            Rectangle {
                id: right_rectangle
                x: 360
                y: 0
                width: 360
                height: 72
                color: "#00000000"
                radius: 10
                visible: showTwoButtons

                Text {
                    id: right_text
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.letterSpacing: 3
                    font.weight: Font.Bold
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    id: right_mouseArea
                    anchors.fill: parent
                    onPressed: {
                        right_rectangle.color = "#ffffff"
                        right_text.color = "#000000"
                    }
                    onReleased: {
                        right_rectangle.color = "#00000000"
                        right_text.color = "#ffffff"
                    }
                }
            }

            Rectangle {
                id: full_button_rectangle
                x: 0
                y: 0
                width: 720
                height: 72
                color: "#00000000"
                radius: 10
                visible: !showTwoButtons

                Text {
                    id: full_button_text
                    color: "#ffffff"
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: false
                    font.letterSpacing: 3
                    font.weight: Font.Bold
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    id: full_button_mouseArea
                    anchors.fill: parent
                    onPressed: {
                        full_button_rectangle.color = "#ffffff"
                        full_button_text.color = "#000000"
                    }
                    onReleased: {
                        full_button_rectangle.color = "#00000000"
                        full_button_text.color = "#ffffff"
                    }
                }
            }
        }

        Container {
            id: popup_contents
            width: basePopupItem.width
            height: showButtonBar ?
                            basePopupItem.height - buttonBar.height :
                            basePopupItem.height
            anchors.top: parent.top
        }
    }
}

