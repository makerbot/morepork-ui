import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9

Button {
    id: menuButton
    height: 96
    anchors.right: parent.right
    anchors.left: parent.left
    smooth: false
    spacing: 0
    property alias buttonText: buttonText
    property alias buttonImage: buttonImage
    property alias buttonAlertImage: buttonAlertImage
    property alias wifiIcons: wifiIcons
    property alias slidingSwitch: slidingSwitch
    property alias openMenuItemArrow: openMenuItemArrow
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"
    enabled: true

    background: Rectangle {
        opacity: menuButton.down ? 1 : 0
        color: menuButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.bottom
        anchors.topMargin: -1
        smooth: false
    }

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: enabled ? 1.0 : 0.3

        RowLayout {
            id: leftSideItems
            height: parent.height
            width: children.width
            spacing: 24
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: buttonImage
                width: sourceSize.width
                height: sourceSize.height
                smooth: false
                antialiasing: false
            }

            TextHeadline {
                id: buttonText
            }
        }

        RowLayout {
            id: rightSideItems
            height: parent.height
            width: children.width
            spacing: 16
            anchors.right: parent.right
            anchors.rightMargin: 32
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: buttonAlertImage
                width: sourceSize.width
                height: sourceSize.height
                smooth: false
                antialiasing: false
                source: "qrc:/img/menu_button_alert.png"
                visible: false
            }

            RowLayout {
                id: wifiIcons
                height: parent.height
                width: children.width
                spacing: 16
                visible: false

                Image {
                    id: wifiSecuredImage
                    width: sourceSize.width
                    height: sourceSize.height
                    smooth: false
                    antialiasing: false
                    source: "qrc:/img/wifi_secured_menu_icon.png"
                }

                Image {
                    id: wifiImage
                    width: sourceSize.width
                    height: sourceSize.height
                    smooth: false
                    antialiasing: false
                    source: "qrc:/img/wifi_menu_icon.png"
                }
            }

            SlidingSwitch {
                id: slidingSwitch
                visible: false
            }

            Image {
                id: openMenuItemArrow
                width: sourceSize.width
                height: sourceSize.height
                source: "qrc:/img/open_menu_item_arrow.png"
                visible: false
            }
        }
    }

    Component.onCompleted: {
        this.onClicked.connect(uiLogBtn)
    }

    function uiLogBtn() {
        console.info("MB [=" + buttonText.text + "=] clicked")
    }
}
