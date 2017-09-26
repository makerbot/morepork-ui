import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 480

    TopDrawer {
        id: drawer
        width: window.width
        height: window.height
    }

    StackLayout {
        id: stackLayout
        anchors.fill: parent

        MainMenu {
            objectName: "testLayout"
            anchors.fill: parent

            //        qtQuickButton_cancel.onClicked: {
            //            //console.log("Button Pressed.")
            //            bot.cancel()
            //        }
        }
    }
}
