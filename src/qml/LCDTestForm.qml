import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 480
    smooth: false
    antialiasing: false
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -30
    property alias lcdTestSwipeView: lcdTestSwipeView
    SwipeView {
        id: lcdTestSwipeView
        smooth: false
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        interactive: true

        Item {
            Rectangle {
                id: rectangleWhite
                anchors.fill: parent
                color: "#ffffff"
                border.width: 0
            }

        }

        Item {
            Rectangle {
                id: rectangleBlack
                anchors.fill: parent
                color: "#000000"
                border.width: 0
            }

        }

        Item {
            Rectangle {
                id: rectangleRed
                anchors.fill: parent
                color: "#ff0000"
                border.width: 0
            }
        }

        Item {
            Rectangle {
                id: rectangleGreen
                anchors.fill: parent
                color: "#00ff00"
                border.width: 0
            }
        }

        Item {
            Rectangle {
                id: rectangleBlue
                anchors.fill: parent
                color: "#0000ff"
                border.width: 0
            }
        }

        Item {
            Rectangle {
                id: rectangleHGradient
                x: 160
                y: -160
                width: 480
                height: 800
                rotation: 90
                border.width: 0
                gradient: Gradient {

                    GradientStop {
                        position: 0
                        color: "#ffffff"
                    }

                    GradientStop {
                        position: 1
                        color: "#000000"
                    }
                }
            }
        }

        Item {
            Rectangle {
                id: rectangleVGradient
                border.width: 0
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#ffffff"
                    }

                    GradientStop {
                        position: 1
                        color: "#000000"
                    }
                }
                anchors.fill: parent
            }
        }

        Item {
            Rectangle {
                id: rectanglePattern
                anchors.fill: parent
                color: "#ffffff"

                Rectangle {
                    id: rectangle9
                    x: 45
                    y: 45
                    width: 100
                    height: 100
                    color: "#000000"
                }

                Text {
                    id: mb_text
                    color: "#000000"
                    text: "MB"
                    font.family: "Tahoma"
                    font.pointSize: 70
                    anchors.horizontalCenterOffset: -40
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
