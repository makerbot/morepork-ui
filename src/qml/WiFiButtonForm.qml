import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: wifiButton
    width: parent.width
    height: 80
    smooth: false
    property bool isSaved: false
    property bool isConnected: false
    property alias wifiName: wifiName.text
    property alias isSecured: image_secured.visible
    property int signalStrength
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: wifiButton.down ? 1 : 0
        color: wifiButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
        anchors.topMargin: 0
        smooth: false
    }

    Image {
        id: isConnectedImage
        width: 34
        height: 34
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 18
        source: "qrc:/img/check_circle_small.png"
        visible: isConnected
    }

    Text {
        id: wifiName
        text: qsTr("WiFi Name")
        anchors.left: parent.left
        anchors.leftMargin: 75
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Antenna"
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }

    Image {
        id: image_secured
        width: sourceSize.width * 1.2
        height: sourceSize.height * 1.2
        anchors.right: parent.right
        anchors.rightMargin: 120
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/lock_icon.png"
    }

    Image {
        id: image_signal_strength
        width: sourceSize.width * 1.2
        height: sourceSize.height * 1.2
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
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
            else if(signalStrength <= 33) {
                "qrc:/img/wifi_poor.png"
            }
        }
    }

}
