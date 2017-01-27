import QtQuick 2.5
import QtQuick.Window 2.2

Window {
    visible: true
    width: 800
    height: 480

    /* Should only show up for desktop UI testing */
    title: qsTr("The morepork UI")

    TestLayout {
        anchors.fill: parent
    }
}
