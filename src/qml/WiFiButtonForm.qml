import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9

Button {
    id: wifiButton
    height: 96
    anchors.right: parent.right
    anchors.left: parent.left
    smooth: false
    spacing: 0
    property bool isSaved: false
    property alias isConnected: isConnectedImage.visible//false
    property alias wifiName: wifiName.text
    property alias isSecured: image_secured.visible
    property int signalStrength
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"
    enabled: true

    background:
        Rectangle {
        opacity: wifiButton.down ? 1 : 0
        color: wifiButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
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

            Item {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34

                Image {
                    id: isConnectedImage
                    width: 34
                    height: 34
                    source: "qrc:/img/process_complete_small.png"
                    smooth: false
                    antialiasing: false
                }
            }

            TextHeadline {
                id: wifiName
                text: qsTr("WiFi Name")
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
                id: image_secured
                Layout.preferredWidth: sourceSize.width
                Layout.preferredHeight: sourceSize.height
                source: "qrc:/img/wifi_secured_menu_icon.png"
            }

            Image {
                id: image_signal_strength
                Layout.preferredWidth: sourceSize.width
                Layout.preferredHeight: sourceSize.height
                source: {
                    if(signalStrength >= 70) {
                        "qrc:/img/wifi_strong.png"
                    }
                    else if(signalStrength >= 45) {
                        "qrc:/img/wifi_medium.png"
                    }
                    else if(signalStrength > 33) {
                        "qrc:/img/wifi_low.png"
                    }
                    else {
                       "qrc:/img/wifi_poor.png"
                   }
                }
            }
        }
    }

    Component.onCompleted: {
        this.onReleased.connect(uiLogBtn)
    }

    function uiLogBtn() {
        console.info("MB [=" + wifiName.text + "=] clicked")
    }
}

