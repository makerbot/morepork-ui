import QtQuick 2.10

MouseArea {
    property string logText: "logText"

    Component.onCompleted: {
        this.onReleased.connect(logClick)
    }

    function logClick() {
        console.info(logText + " clicked")
    }
}
