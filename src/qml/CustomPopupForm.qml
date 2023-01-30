import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

LoggingPopup {
    id: popup
    width: rootAppWindow.width
    height: rootAppWindow.height
    modal: true
    dim: false
    focus: true
    parent: overlay
    closePolicy: Popup.NoAutoClose

    enum DefaultButton {
        None,
        Left,
        Right
    }

    property alias popupContainer: popupContainer
    property alias popupWidth: popupContainer.width
    property alias popupHeight: popupContainer.height
    property alias full_button: full_button
    property alias full_button_text: full_text.text
    property alias left_button: left_button
    property alias left_button_text: left_text.text
    property alias right_button: right_button
    property alias right_button_text: right_text.text
    property bool showOneButton: false
    property bool showTwoButtons: false
    property int defaultButton: CustomPopup.Right

    background: Rectangle {
        id: popupBackgroundDim
        color: "#000000"
        rotation: rootItem.rotation == 180 ? 180 : 0
        opacity: 0.5
        anchors.fill: parent
    }
    enter: Transition {
        NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
    }

    // Added for when we need to use Popup.CloseOnPressOutside
    // Top Outside
    MouseArea {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: popupContainer.top

        onClicked: {
            if(closePolicy == Popup.CloseOnPressOutside) {
                popup.close()
            }
        }
    }
    // Right Outside
    MouseArea {
        anchors.top: parent.top
        anchors.left: popupContainer.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        onClicked: {
            if(closePolicy == Popup.CloseOnPressOutside) {
                popup.close()
            }
        }
    }
    // Left Outside
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: popupContainer.left
        anchors.bottom: parent.bottom

        onClicked: {
            if(closePolicy == Popup.CloseOnPressOutside) {
                popup.close()
            }
        }
    }
    // Bottom Outside
    MouseArea {
        anchors.top: popupContainer.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        onClicked: {
            if(closePolicy == Popup.CloseOnPressOutside) {
                popup.close()
            }
        }
    }

    Rectangle {
        id: popupContainer
        color: "#000000"
        rotation: rootItem.rotation == 180 ? 180 : 0
        width: 720
        height: 265
        radius: 10
        border.width: 2
        border.color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        // Opacity Mask used so buttons can fill entire space
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: popupContainer.width
                height: popupContainer.height
                Rectangle {
                    anchors.centerIn: parent
                    width: popupContainer.width
                    height: popupContainer.height
                    radius: 10
                }
             }
        }

        Item {
            id: buttonBar
            width: parent.width
            height: 72
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            visible: showOneButton || showTwoButtons

            Rectangle {
                id: horizontal_divider
                width: parent.width
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.top
                anchors.bottomMargin: 0
            }

            Item {
                id: full_button_item
                anchors.fill: parent
                visible: showOneButton

                Rectangle {
                    id: full_button_rectangle
                    anchors.fill: parent
                    color: "#00000000"

                    Text {
                        id: full_text
                        color: "#ffffff"
                        text: qsTr("CANCEL")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "CPFB [_" + full_button_text + "_]"
                        id: full_button
                        anchors.fill: parent
                        onPressed: {
                            full_button_rectangle.color = "#ffffff"
                            full_text.color = "#000000"
                        }
                        onReleased: {
                            full_button_rectangle.color = "#00000000"
                            full_text.color = "#ffffff"
                        }
                    }
                }
            }

            Item {
                id: two_button_item
                anchors.fill: parent
                visible: showTwoButtons

                Rectangle {
                    id: vertical_divider
                    width: 2
                    height: parent.height
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                }

                Rectangle {
                    id: left_rectangle
                    width: parent.width/2
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    color: (defaultButton === CustomPopup.Left ? "#ffffff" : "#00000000")
                    visible: true

                    Text {
                        id: left_text
                        color: (defaultButton === CustomPopup.Left ? "#000000" : "#ffffff")
                        text: qsTr("LEFT TEXT")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "CPLB [_" + left_button_text + "|]"
                        id: left_button
                        anchors.fill: parent
                        onPressed: {
                            left_text.color = (defaultButton === CustomPopup.Left ? "#ffffff" : "#000000")
                            left_rectangle.color = (defaultButton === CustomPopup.Left ? "#00000000" : "#ffffff")
                        }
                        onReleased: {
                            left_text.color = (defaultButton === CustomPopup.Left ? "#000000" : "#ffffff")
                            left_rectangle.color = (defaultButton === CustomPopup.Left ? "#ffffff" : "#00000000")
                        }
                    }
                }

                Rectangle {
                    id: right_rectangle
                    width: parent.width/2
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: (defaultButton === CustomPopup.Right ? "#ffffff" : "#00000000")
                    visible: true

                    Text {
                        id: right_text
                        color: (defaultButton === CustomPopup.Right ? "#000000" : "#ffffff")
                        text: qsTr("RIGHT TEXT")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText:"CPRB [|" + right_button_text + "_]"
                        id: right_button
                        anchors.fill: parent
                        onPressed: {
                            right_text.color = (defaultButton === CustomPopup.Right ? "#ffffff" : "#000000")
                            right_rectangle.color = (defaultButton === CustomPopup.Right ? "#00000000" : "#ffffff")
                        }
                        onReleased: {
                            right_text.color = (defaultButton === CustomPopup.Right ? "#000000" : "#ffffff")
                            right_rectangle.color = (defaultButton === CustomPopup.Right ? "#ffffff" : "#00000000")
                        }
                    }
                }
            }
        }
    }
}
