import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: timeZoneButton
    width: parent.width
    height: 80
    smooth: false

    onClicked: {
        // Referenced to parent page
        timeZoneSelectorPage.setTimeZone(timeZonePathName)
    }

    property string timeZonePathName
    property alias isSelected: isSelectedImage.visible
    property alias timeZoneCode: timeZoneCodeText.text
    property alias timeZoneName: timeZoneNameText.text
    property alias timeZoneGMTReference: timeZoneGMTReferenceText.text
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: timeZoneButton.down ? 1 : 0
        color: timeZoneButton.down ? buttonPressColor : buttonColor
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
        id: isSelectedImage
        width: 34
        height: 34
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 32
        source: "qrc:/img/check_circle_small.png"
        visible: bot.timeZone == timeZonePathName
    }

    Text {
        id: timeZoneCodeText
        text: qsTr("UTC")
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
        visible: !isSelectedImage.visible
    }

    Text {
        id: timeZoneNameText
        text: qsTr("UNIVERSAL COORDINATED TIME")
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }

    Text {
        id: timeZoneGMTReferenceText
        text: qsTr("GMT")
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }
}
