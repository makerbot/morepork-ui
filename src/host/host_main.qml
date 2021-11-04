import QtQuick 2.5
import QtQuick.Window 2.2
import "../qml" as Ui
// import events_logging 1.0

QtObject {
    property var modelWindow: Window {
        visible: true
        width: 440
        height: 800
        x: 840
        y: 0
        title: "Bot Model"

        Model {
            anchors.fill: parent
        }

    }

    property var uiWindow: Ui.MoreporkUI {
        x: 0
        y: 0
        title: "The morepork UI"
    }

    // Component.onCompleted: UiEventLogger.beginUiLogging(modelWindow)
}

