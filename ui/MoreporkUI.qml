import QtQuick 2.5
import QtQuick.Window 2.2

Window {
    visible: true
    width: 800
    height: 480

    TestLayout {
        objectName: "testLayout"
        anchors.fill: parent

        mouseArea_cancelPrint.onClicked: {
            //console.log("Button Pressed.")
            bot.cancelPrint()
        }
    }
}
