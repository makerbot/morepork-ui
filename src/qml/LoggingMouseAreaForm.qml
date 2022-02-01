import QtQuick 2.10

MouseArea {
    property string logText: "logText"

    Component.onCompleted: {
        this.onClicked.connect(logClick)
    }

    function logClick() {
        console.log(logText + " clicked")
    }
}
