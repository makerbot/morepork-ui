import QtQuick 2.12

Item {
    property int frameCounter: 0
    property int frameCounterAvg: 0
    property int counter: 0
    property int fps: 0
    property int fpsAvg: 0

    width:  300
    height: 100

    Image {
        id: spinnerImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        width: sourceSize.width
        height: sourceSize.height
        source: "qrc:/img/icon_factory_reset.png"
        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 800
            loops: Animation.Infinite
        }
        onRotationChanged: frameCounter++
    }

    Text {
        anchors.left: spinnerImage.right
        anchors.leftMargin: 5
        anchors.verticalCenter: spinnerImage.verticalCenter
        color: "#c0c0c0"
        font.pixelSize: 20
        text: fpsAvg + " avg fps | " + fps + " fps"
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            frameCounterAvg += frameCounter
            fps = frameCounter/2
            counter++
            frameCounter = 0
            if (counter >= 3) {
                fpsAvg = frameCounterAvg/(2*counter)
                frameCounterAvg = 0
                counter = 0
            }
        }
    }
}
