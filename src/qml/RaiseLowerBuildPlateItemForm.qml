import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: item1
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Text {
        id: distance_text
        color: "#ffffff"
        text: "DISTANCE (mm)"
        anchors.horizontalCenterOffset: -80
        anchors.bottom: row.top
        anchors.bottomMargin: 50
        anchors.horizontalCenter: row.horizontalCenter
        font.weight: Font.Light
        font.family: "Antennae"
        font.pixelSize: 20
    }

    Text {
        id: speed_text
        color: "#ffffff"
        text: "SPEED (mm/s)"
        anchors.horizontalCenterOffset: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: row.top
        anchors.bottomMargin: 50
        font.weight: Font.Light
        font.family: "Antennae"
        font.pixelSize: 20
    }

    Row {
        id: row
        width: 300
        anchors.left: parent.left
        anchors.leftMargin: 100
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter

        Tumbler {
            id: distanceTumbler
            width: 150
            height: 200
            font.pointSize: 20
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: [1,2,3,5,10,15,25,50,100]
        }

        Rectangle {
            id: spacingItem
            width: 100
            height: 10
            color: "#000000"
        }

        Tumbler {
            id: speedTumbler
            width: 150
            height: 200
            font.pointSize: 20
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: [5,10,15,20]
        }
    }

    ColumnLayout {
        id: columnLayout
        width: 100
        height: 150
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        spacing: 50

        RoundedButton {
            id: moveUpButton
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            buttonHeight: 75
            buttonWidth: 120
            label: "UP"
            label_size: 20

            opacity: {
                button_mouseArea.enabled ? 1.0 : 0.1
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: 200
                }
            }

            button_mouseArea {
                onClicked: {
                    bot.moveAxis("z", -distanceTumbler.model[distanceTumbler.currentIndex],
                                       speedTumbler.model[speedTumbler.currentIndex])
                }
                enabled: {
                    !distanceTumbler.moving && !speedTumbler.moving
                }
            }
        }

        RoundedButton {
            id: moveDownButton
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            buttonHeight: 75
            buttonWidth: 120
            label: "DOWN"
            label_size: 20

            opacity: {
                button_mouseArea.enabled ? 1.0 : 0.1
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: 200
                }
            }

            button_mouseArea {
                onClicked: {
                    bot.moveAxis("z", distanceTumbler.model[distanceTumbler.currentIndex],
                                      speedTumbler.model[speedTumbler.currentIndex])
                }
                enabled: {
                    !distanceTumbler.moving && !speedTumbler.moving
                }
            }
        }
    }
}
