import QtQuick 2.12
import QtQuick.Controls 2.12

Popup {
    property string popupName: "Default"

    Component.onCompleted: {
        this.onOpened.connect(logOpened)
        this.onClosed.connect(logClosed)
    }

    function logOpened() {
        console.info("Popup", popupName, "Opened")
    }

    function logClosed() {
        console.info("Popup", popupName, "Closed")
    }
}
