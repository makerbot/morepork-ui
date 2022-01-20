import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: control
    width: 52
    height: 52
    text: qsTr("Button")
    antialiasing: true
    flat: true

    contentItem: Image {
        source: "qrc:/img/play.png"
    }

    background: Rectangle {
        implicitWidth: 52
        implicitHeight: 52
        color: enabled ? (control.down ? "#B2B2B2" : "#FFFFFF") : "#808080"
        radius: 26
            Text {
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
            anchors.top: parent.bottom
            anchors.topMargin: 14.5
        }
    }

    Component.onCompleted: {
        this.onClicked.connect(logClick)
    }

    function logClick() {
        console.log("ButtonRoundPrintIcon " + text + " clicked")
    }
}
