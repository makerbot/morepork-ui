import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ModalPopup {
    property string busyPopupText: busyPopupText

    id: busyPopup

    showButtonBar: false
    disableUserClose: true

    popup_contents.contentItem: Item {
        BusyIndicator {
            id: busyIndicator

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 60

            running: parent.visible

            contentItem: Item {
                implicitWidth: 64
                implicitHeight: 64

                Item {
                    id: busySpinner
                    x: parent.width / 2 - 32
                    y: parent.height / 2 - 32
                    width: 64
                    height: 64

                    RotationAnimator {
                        target: busySpinner
                        running: busySpinner.visible
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 1500
                    }

                    Repeater {
                        id: busySpinnerImage
                        model: 6

                        Rectangle {
                            x: busySpinner.width / 2 - width / 2
                            y: busySpinner.height / 2 - height / 2
                            implicitWidth: 2
                            implicitHeight: 16
                            radius: 0
                            color: "#ffffff"
                            transform: [
                                Translate {
                                    y: -Math.min(busySpinner.width, busySpinner.height) * 0.5 + 5
                                },
                                Rotation {
                                    angle: index / busySpinnerImage.count * 360
                                    origin.x: 1
                                    origin.y: 8
                                }
                            ]
                        }
                    }
                }
            }
        }

        TitleText {
            id: busyPopupMessage
            text: busyPopupText
            anchors.horizontalCenter: busyIndicator.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
        }
    }
}
