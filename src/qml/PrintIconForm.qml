import QtQuick 2.10
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

ColumnLayout {
    spacing: 20
    height: children.height
    property bool showActionButtons: true

    LoggingItem {
        itemName: "PrintIcon"
        width: 250
        height: 250
        smooth: false
        Layout.alignment: Qt.AlignHCenter
        backgroundColor: "#00000000"

        Rectangle {
            id: base_circle
            anchors.fill: parent
            color: "#00000000"
            radius: 125
            border.width: 3
            border.color: "#484848"
            antialiasing: true
            smooth: true

            property int percent: bot.process.printPercentage
            property int printState: bot.process.stateType
            property string progressColor: {
                switch(printState) {
                case ProcessStateType.Completed:
                    "#3183AF"
                    break;
                case ProcessStateType.Failed:
                case ProcessStateType.Cancelled:
                    "#F79125"
                    break;
                default:
                    "#FFFFFF"
                    break;
                }
            }

            onPrintStateChanged: canvas.requestPaint()
            onPercentChanged: canvas.requestPaint()

            Canvas {
                id: canvas
                visible: false
                antialiasing: false
                smooth: false
                rotation : -90
                anchors.fill: parent
                onPaint: {
                    var context = getContext("2d");
                    context.reset();

                    var centreX = parent.width*0.5;
                    var centreY = parent.height*0.5;

                    context.beginPath();
                    //0.06283185 = PI*2/100
                    context.arc(centreX, centreY, parent.width*0.5-15, 0,
                                parent.percent*0.06283185, false);
                    context.lineWidth = 10;
                    context.lineCap = "round";
                    context.strokeStyle = parent.progressColor;
                    context.stroke()
                }
            }

            Image {
                id: status_image
                width: 68
                height: 68
                smooth: false
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/img/loading_gears.png"
                visible: (bot.process.stateType == ProcessStateType.Loading ||
                          bot.process.stateType == ProcessStateType.Preheating ||
                          bot.process.stateType == ProcessStateType.Cancelling ||
                          bot.process.stateType == ProcessStateType.CleaningUp ||
                          bot.process.stateType == ProcessStateType.Done || // Part of cancelling step
                          bot.process.stateType == ProcessStateType.Failed ||
                          bot.process.stateType == ProcessStateType.Completed ||
                          bot.process.stateType == ProcessStateType.Cancelled)

                RotationAnimator {
                    target: status_image
                    from: 360
                    to: 0
                    duration: 10000
                    loops: Animation.Infinite
                    running: (bot.process.stateType == ProcessStateType.Loading ||
                             bot.process.stateType == ProcessStateType.Preheating ||
                             bot.process.stateType == ProcessStateType.Cancelling ||
                             bot.process.stateType == ProcessStateType.CleaningUp ||
                             bot.process.stateType == ProcessStateType.Done)
                }
            }

            Image {
                id: loading_or_paused_image
                width: 235
                height: 235
                smooth: false
                source: "qrc:/img/loading_rings.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: (bot.process.stateType == ProcessStateType.Loading ||
                          bot.process.stateType == ProcessStateType.Paused ||
                          bot.process.stateType == ProcessStateType.Pausing ||
                          bot.process.stateType == ProcessStateType.Resuming ||
                          bot.process.stateType == ProcessStateType.Preheating || // Out of filament
                          bot.process.stateType == ProcessStateType.UnloadingFilament || // while printing
                          bot.process.stateType == ProcessStateType.Cancelling ||
                          bot.process.stateType == ProcessStateType.CleaningUp || // Part of cancelling step
                          bot.process.stateType == ProcessStateType.Done) // Part of cancelling step

                RotationAnimator {
                    target: loading_or_paused_image
                    from: 0
                    to: 360
                    duration: 10000
                    loops: Animation.Infinite
                    running: parent.visible
                }
            }

            Text {
                id: percentage_printing_text
                color: "#ffffff"
                text: bot.process.printPercentage
                antialiasing: false
                smooth: false
                anchors.verticalCenterOffset: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: false
                font.family: defaultFont.name
                font.weight: Font.Light
                font.pixelSize: 75

                Text {
                    id: percentage_symbol_text
                    color: "#ffffff"
                    text: "%"
                    antialiasing: false
                    smooth: false
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    visible: false
                    anchors.right: parent.right
                    anchors.rightMargin: -30
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pixelSize: 25
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
                    target: percentage_printing_text
                    visible: true
                }

                PropertyChanges {
                    target: canvas
                    visible: true
                }

                PropertyChanges {
                    target: percentage_symbol_text
                    visible: true
                }

            },
            State {
                name: "paused_state"
                when: bot.process.stateType == ProcessStateType.Paused ||
                      bot.process.stateType == ProcessStateType.Pausing ||
                      bot.process.stateType == ProcessStateType.Resuming ||
                      bot.process.stateType == ProcessStateType.Preheating || // Out of filament
                      bot.process.stateType == ProcessStateType.UnloadingFilament // while printing

                PropertyChanges {
                    target: status_image
                    visible: false
                }

                PropertyChanges {
                    target: percentage_printing_text
                    visible: true
                }

                PropertyChanges {
                    target: canvas
                    visible: false
                }

                PropertyChanges {
                    target: loading_or_paused_image
                    width: 224
                    height: 224
                    source: "qrc:/img/paused_rings.png"
                    visible: true
                }

                PropertyChanges {
                    target: percentage_symbol_text
                    visible: true
                }
            },
            State {
                name: "print_complete_state"
                when: bot.process.stateType == ProcessStateType.Completed

                PropertyChanges {
                    target: loading_or_paused_image
                    visible: false
                }

                PropertyChanges {
                    target: canvas
                    visible: true
                }

                PropertyChanges {
                    target: status_image
                    width: 79
                    height: 59
                    rotation: 0
                    source: "qrc:/img/check_mark.png"
                }
            },
            State {
                name: "print_failed_state"
                when: bot.process.stateType == ProcessStateType.Failed ||
                      bot.process.stateType == ProcessStateType.Cancelled

                PropertyChanges {
                    target: loading_or_paused_image
                    visible: false
                }

                PropertyChanges {
                    target: canvas
                    visible: true
                }

                PropertyChanges {
                    target: status_image
                    width: 16
                    height: 89
                    rotation: 0
                    source: "qrc:/img/exc_mark.png"
                }
            }
        ]
    }

    RowLayout {
        id: actionButtons
        visible: showActionButtons
        spacing: 0
        Layout.alignment: Qt.AlignHCenter

        ButtonRoundPrintIcon {
            id: pauseResumePrintButton

            buttonImage: (bot.process.stateType == ProcessStateType.Paused ||
                           bot.process.stateType == ProcessStateType.Pausing ||
                           bot.process.stateType == ProcessStateType.Resuming ||
                           bot.process.stateType == ProcessStateType.Preheating ||
                           bot.process.stateType == ProcessStateType.UnloadingFilament) ?
                              "qrc:/img/play.png" : "qrc:/img/pause.png"

            buttonText: (bot.process.stateType == ProcessStateType.Paused ||
                         bot.process.stateType == ProcessStateType.Pausing ||
                         bot.process.stateType == ProcessStateType.Resuming ||
                         bot.process.stateType == ProcessStateType.Preheating ||
                         bot.process.stateType == ProcessStateType.UnloadingFilament) ?
                            qsTr("RESUME") : qsTr("PAUSE")

            mouseArea.onClicked: {
                switch(bot.process.stateType) {
                    case ProcessStateType.Printing:
                        //In Printing State
                        bot.pauseResumePrint("suspend")
                        break;
                    case ProcessStateType.Paused:
                        //In Paused State
                        bot.pauseResumePrint("resume")
                    break;
                default:
                    break;
                }
            }

            enabled: (bot.process.stateType == ProcessStateType.Paused ||
                      bot.process.stateType == ProcessStateType.Printing)
        }

        ButtonRoundPrintIcon {
            id: cancelPrintButton
            buttonImage: "qrc:/img/cancel.png"
            buttonText: qsTr("CANCEL")

            mouseArea.onClicked: {
                if(inFreStep) {
                    skipFreStepPopup.open()
                    return;
                 }
                cancelPrintPopup.open()
            }
        }
    }
}
