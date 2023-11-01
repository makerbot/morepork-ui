import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.12

Button {
    id: drawerButton
    width: parent.width
    height: 100
    smooth: false
    antialiasing: false

    property alias buttonText: buttonText.text
    property alias buttonImage: buttonImage.source
    property color buttonBackgroundColor: "#333333"
    property color buttonPressBackgroundColor: "#ffffff"
    property color buttonContentColor: "#ffffff"
    property color buttonPressContentColor: "#000000"

    opacity: enabled ? 1 : 0.25

    background:
        Rectangle {
        id: rectangle
            z: 0
            anchors.fill: parent
            color: "#000000"

            Rectangle {
                z: 1
                width: drawerButton.width - 65
                height: 75
                radius: 8
                color: drawerButton.down ? buttonPressBackgroundColor : buttonBackgroundColor
                smooth: false
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

    contentItem:
        Item {
            anchors.fill: parent
            Image {
                z: 1
                id: buttonImage
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 60
                anchors.verticalCenter: parent.verticalCenter
                smooth: false
                antialiasing: false
            }

            TextBody {
                id: buttonText
                style: TextBody.ExtraLarge
                text: qsTr("Drawer Button Text")
                color: drawerButton.down ? buttonPressContentColor : buttonContentColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.leftMargin: 120
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
            }
        }

    ColorOverlay {
       anchors.fill: contentItem
       source: contentItem
       color: drawerButton.down ? buttonPressContentColor : "#00000000"
   }

    Component.onCompleted: {
        this.onReleased.connect(logClick)
    }

    function logClick() {
        console.info("DrawerButton [[@]" + buttonText.text + "] clicked")
    }
}
