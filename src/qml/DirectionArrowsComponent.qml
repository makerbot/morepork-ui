import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12

Item {
    id: arrowsComponent
    property bool upEnabled: false
    property bool downEnabled: false

    function direction() {
        if(upEnabled) {
            return -1
        } else if (downEnabled) {
            return 1
        } else {
            return 0
        }
    }

    ColumnLayout {
        id: directionColumn
        height: children.height
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 70

        Image {
            id: upArrow
            width: sourceSize.width
            Layout.preferredWidth: width
            height: sourceSize.height
            Layout.preferredHeight: height
            source: upEnabled ? "qrc:/img/vector_up_enabled.png"
                              : "qrc:/img/vector_down_disabled.png"
            rotation: upEnabled ? 0 : 180
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.centerIn: parent
                width: 60
                height: 60
                onClicked: {
                    console.log("Height " + height + " width " + width)
                    downEnabled= false
                    upEnabled= true
                }
            }
        }

        Image {
            id: downArrow
            width: sourceSize.width
            Layout.preferredWidth: width
            height: sourceSize.height
            Layout.preferredHeight: height
            source: downEnabled ? "qrc:/img/vector_up_enabled.png"
                                : "qrc:/img/vector_down_disabled.png"
            rotation: downEnabled ? 180 : 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.centerIn: parent
                width: 60
                height: 60
                onClicked: {
                    upEnabled = false
                    downEnabled = true
                }
            }
        }

    }
}
