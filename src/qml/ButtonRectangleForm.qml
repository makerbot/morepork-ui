import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: control
    width: 360
    height: 52
    text: qsTr("Button")
    antialiasing: true
    flat: true
    property alias label: text

    contentItem: Text {
        text: control.text
        font: "Antenna"
        font.pixelSize: 17
        font.weight: Font.Bold
        font.letterSpacing: 3.2
        font.capitalization: Font.AllUppercase
        lineHeightMode: Text.FixedHeight
        lineHeight: 20
        color: "#000000"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 136
        implicitHeight: 52
        color: enabled ? (control.down ? "#B2B2B2" : "#FFFFFF") : "#808080"
        radius: 5
    }

    Component.onCompleted: {
        this.onClicked.connect(logClick)
    }

    function logClick() {
        console.log("ButtonRectangle " + label + " clicked")
    }
}
