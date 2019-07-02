import QtQuick 2.0
import QtQuick.Controls 2.2

Button {
    id: moreporkButton
    height: 100
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias buttonText: buttonText
    property alias buttonImage: buttonImage
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"
    property bool disableButton: false

    background: Rectangle {
        opacity: moreporkButton.down ? 1 : 0
        color: moreporkButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Image {
        id: buttonImage
        width: 34
        height: 34
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false
        opacity: disableButton ? 0.2 : 1
    }

    contentItem: Text {
        id: buttonText
        text: qsTr("MoreporkButton Text")
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        color: disableButton ? "#545454" : "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        smooth: false
        antialiasing: false
    }
}
