import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item {
    id: itemTopBarForm
    property alias itemTopBarForm: itemTopBarForm
    // You will always want to reference pages off barHeight or
    // topFadeIn.height depending on what you are doing.
    property int barHeight: 40
    height: topFadeIn.height
    property alias topFadeIn: topFadeIn
    property alias imageDrawerArrow: imageDrawerArrow
    property alias backButton: backButton
    property alias notificationIcons: notificationIcons
    signal backClicked()
    signal drawerDownClicked()

    Item {
        id: itemNotificationIcons
        width: 130
        height: 40
        z: 2
        anchors.right: parent.right
        anchors.rightMargin: 0

        NotificationIconsForm
        {
            id: notificationIcons
            anchors.fill: parent
        }
    }

    LinearGradient {
        id: topFadeIn
        height: 60
        cached: true
        z: 1
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        gradient: Gradient {
            GradientStop {
                position: 0.6
                color: "#FF000000"
            }
            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
    }

    Item {
        id: backButton
        width: 150
        height: barHeight
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 2

        MouseArea {
            id: mouseArea_back
            height: topFadeIn.height
            anchors.leftMargin: -parent.anchors.leftMargin
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            onClicked: backClicked()
        }

        Image {
            id: imageBackArrow
            height: 25
            anchors.verticalCenterOffset: -1
            anchors.verticalCenter: text_back.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/arrow_19pix.png"
        }

        Text {
            id: text_back
            width: 200
            color: "#a0a0a0"
            text: qsTr("BACK") + cpUiTr.emptyStr
            verticalAlignment: Text.AlignVCenter
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageBackArrow.right
            anchors.leftMargin: 5
        }
    }

    Item {
        id: itemPrinterName
        height: barHeight
        z: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        property alias text_printerName: textPrinterName

        Text {
            id: textPrinterName
            color: "#a0a0a0"
            text: bot.name
            verticalAlignment: Text.AlignVCenter
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Image {
            id: imageDrawerArrow
            y: 227
            height: 25
            anchors.left: textPrinterName.right
            anchors.leftMargin: 10
            anchors.verticalCenter: textPrinterName.verticalCenter
            rotation: -90
            z: 1
            source: "qrc:/img/arrow_19pix.png"
            fillMode: Image.PreserveAspectFit

            MouseArea {
                id: mouseAreaTopDrawerDown
                width: 40
                height: 60
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z: 2
                onClicked: drawerDownClicked()
            }
        }
    }


}
