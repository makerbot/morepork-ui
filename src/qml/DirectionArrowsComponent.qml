import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12

Item {
    id: arrowsComponent
    property bool upEnabled: false
    property bool downEnabled: false
    property int arrowWidth: parent.width
    property int arrowHeight: parent.height/2

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
            source: "qrc:/img/vector_image.png"
            opacity: upEnabled ? 1 : 0.3
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.centerIn: parent
                width: arrowWidth
                height: arrowHeight
                onClicked: {
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
            source: "qrc:/img/vector_image.png"
            opacity: downEnabled ? 1 : 0.3
            rotation: 180
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.centerIn: parent
                width: arrowWidth
                height: arrowHeight
                onClicked: {
                    upEnabled = false
                    downEnabled = true
                }
            }
        }

    }
}
