import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: item1
    property alias spinnerActive: busyIndicator.visible
    property int spinnerSize: 64
    property int spokeWidth: 2
    property int spokeHeight: spinnerSize / 4

    width: spinnerSize
    height: spinnerSize

    BusyIndicator {
        id: busyIndicator
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenterOffset: -2
        running: true
        contentItem: Item {
                implicitWidth: spinnerSize
                implicitHeight: spinnerSize

                Item {
                    id: baseItem
                    x: parent.width / 2 - spinnerSize / 2
                    y: parent.height / 2 - spinnerSize / 2
                    width: spinnerSize
                    height: spinnerSize
                    opacity: busyIndicator.running ? 1 : 0

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 250
                        }
                    }

                    RotationAnimator {
                        target: baseItem
                        running: busyIndicator.visible && busyIndicator.running
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 2000
                    }

                    Repeater {
                        id: repeater
                        model: 6

                        Rectangle {
                            x: baseItem.width / 2 - width / 2
                            y: baseItem.height / 2 - height / 2
                            implicitWidth: spokeWidth
                            implicitHeight: spokeHeight
                            radius: 0
                            color: "#ffffff"
                            transform: [
                                Translate {
                                    y: -Math.min(baseItem.width, baseItem.height) * 0.5 + 5
                                },
                                Rotation {
                                    angle: index / repeater.count * 360
                                    origin.x: spokeWidth/2
                                    origin.y: spokeHeight/2
                                }
                            ]
                        }
                    }
                }
            }
    }
}
