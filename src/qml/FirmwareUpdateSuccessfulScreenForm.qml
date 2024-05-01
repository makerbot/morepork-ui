import QtQuick 2.10

Item {
    id: item1
    anchors.fill: parent

    // Make this overlay screen opaque to touches.
    MouseArea {
        id: emptyMouseArea
        z: -1
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    ContentLeftSide {
        anchors.verticalCenter: parent.verticalCenter
        visible: true
        processStatusIcon {
            id: update_successful_image
            processStatus: ProcessStatusIcon.Success
            visible: true
        }
    }

    ContentRightSide {
        anchors.verticalCenter: parent.verticalCenter
        visible: true
        textHeader {
            text: qsTr("FIRMWARE %1 SUCCESSFULLY INSTALLED").arg(bot.version)
            visible: true
        }
        buttonPrimary {
            text: qsTr("CONTINUE")
            visible: true
            onClicked: {
                fre.acknowledgeFirstBoot()
            }
        }
    }
}
