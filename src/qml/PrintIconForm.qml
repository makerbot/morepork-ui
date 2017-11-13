import QtQuick 2.4
import ProcessStateTypeEnum 1.0

Item {
    id: item1
    width: 250
    height: 265
    property alias action_mouseArea: action_mouseArea
    property alias percentage_printing_text: percentage_printing_text
    property alias status_image: status_image
    property alias loading_or_paused_image: loading_or_paused_image
    property alias canvas: canvas
    property bool actionButton: true

    Rectangle {
        id: base_circle
        width: 250
        height: 250
        color: "#00000000"
        radius: 125
        anchors.top: parent.top
        anchors.topMargin: 0
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        border.width: 3
        border.color: "#484848"

        Rectangle {
            id: progress_circle
            width: 224
            height: 224
            color: "#00000000"
            radius: 112
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            property int percent: bot.process.printPercentage
            property int printState: bot.process.stateType
            property string progressColor:
                switch(printState)
                {
                case ProcessStateType.PrintComplete:
                    "#3183AF"
                    break;
                case ProcessStateType.Failed:
                    "#F79125"
                    break;
                default:
                    "#FFFFFF"
                    break;
                }

            onPrintStateChanged: canvas.requestPaint()
            onPercentChanged: canvas.requestPaint()
            Canvas {
                id: canvas
                rotation : -90
                anchors.fill: parent
                onPaint:
                {
                    var context = getContext("2d");
                    context.reset();

                    var centreX = parent.width / 2;
                    var centreY = parent.height / 2;

                    context.beginPath();
                    context.arc(centreX, centreY, (parent.width / 2) - 5, 0,
                                (Math.PI*(2.0*parent.percent/100)), false);
                    context.lineWidth = 10;
                    context.strokeStyle = parent.progressColor;
                    context.stroke()
                }
            }
        }

        Image {
            id: status_image
            width: 68
            height: 68
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/loading_gears.png"

            RotationAnimator {
                target: status_image;
                from: 360000;
                to: 0;
                duration: 10000000
                running: (bot.process.stateType == ProcessStateType.Loading)
            }
        }

        Image {
            id: loading_or_paused_image
            width: 214
            height: 214
            source: "qrc:/img/loading_rings.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            RotationAnimator {
                target: loading_or_paused_image;
                from: 0;
                to: 360000;
                duration: 10000000
                running: (bot.process.stateType == ProcessStateType.Loading ||
                          bot.process.stateType == ProcessStateType.Paused)
            }
        }

        Text {
            id: percentage_printing_text
            color: "#ffffff"
            text: bot.process.printPercentage
            anchors.verticalCenterOffset: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            visible: false
            font.family: "Antenna"
            font.weight: Font.Light
            font.pixelSize: 75

            Text {
                id: percentage_symbol_text
                color: "#ffffff"
                text: "%"
                anchors.top: parent.top
                anchors.topMargin: 2
                visible: false
                anchors.right: parent.right
                anchors.rightMargin: -30
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Antenna"
                font.weight: Font.Light
                font.pixelSize: 25
            }
        }

        Rectangle {
            id: action_circle
            width: 60
            height: 60
            color: "#000000"
            radius: 30
            anchors.top: parent.top
            anchors.topMargin: 201
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            border.width: 3
            border.color: "#484848"

            Image {
                id: action_image
                width: 45
                height: 45
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: action_mouseArea
                anchors.fill: parent
            }
        }
    }

    states: [
        State {
            name: "printing_state"
            when: bot.process.stateType == ProcessStateType.Printing

            PropertyChanges {
                target: status_image
                visible: false
            }

            PropertyChanges {
                target: loading_or_paused_image
                visible: false
            }

            PropertyChanges {
                target: action_circle
                visible: actionButton
            }

            PropertyChanges {
                target: percentage_printing_text
                visible: true
            }

            PropertyChanges {
                target: progress_circle
                visible: true
            }

            PropertyChanges {
                target: percentage_symbol_text
                visible: true
            }

            PropertyChanges {
                target: action_image
                source: "qrc:/img/pause.png"
            }
        },
        State {
            name: "paused_state"
            when: bot.process.stateType == ProcessStateType.Paused

            PropertyChanges {
                target: status_image
                visible: false
            }

            PropertyChanges {
                target: action_circle
                visible: actionButton
            }

            PropertyChanges {
                target: percentage_printing_text
                visible: true
            }

            PropertyChanges {
                target: progress_circle
                visible: false
            }

            PropertyChanges {
                target: loading_or_paused_image
                width: 224
                height: 224
                source: "qrc:/img/paused_rings.png"
            }

            PropertyChanges {
                target: action_image
                source: "qrc:/img/play.png"
            }

            PropertyChanges {
                target: percentage_symbol_text
                visible: true
            }

        },
        State {
            name: "print_complete_state"
            when: bot.process.stateType == ProcessStateType.PrintComplete

            PropertyChanges {
                target: loading_or_paused_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                visible: true
            }
            PropertyChanges {
                target: status_image
                width: 79
                height: 59
                rotation: 0
                source: "qrc:/img/check_mark.png"
                visible: true
            }

        },
        State {
            name: "print_failed_state"
            when: bot.process.stateType == ProcessStateType.Failed

            PropertyChanges {
                target: loading_or_paused_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                visible: true
            }
            PropertyChanges {
                target: status_image
                width: 16
                height: 89
                rotation: 0
                source: "qrc:/img/exc_mark.png"
                visible: true
            }

        }
    ]
}
