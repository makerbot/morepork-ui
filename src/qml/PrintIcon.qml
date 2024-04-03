import QtQuick 2.12
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

ColumnLayout {
    spacing: 20
    height: children.height
    width: children.width
    property bool showActionButtons: true

    ProcessStatusIcon {
        itemName: "PrintIcon"
        process: ProcessStatusIcon.PrintProcess
        Layout.alignment: Qt.AlignHCenter

        states: [
            State {
                name: "print_loading"
                extend: "loading"
                when: bot.process.stateType == ProcessStateType.Loading ||
                      bot.process.stateType == ProcessStateType.Preheating || // Also out of filament while printing along with UnloadingFilament
                      bot.process.stateType == ProcessStateType.Pausing ||
                      bot.process.stateType == ProcessStateType.Resuming ||
                      bot.process.stateType == ProcessStateType.UnloadingFilament || // Out of filament while printing along with Preheating
                      bot.process.stateType == ProcessStateType.Cancelling ||
                      bot.process.stateType == ProcessStateType.CleaningUp ||  // Part of cancelling step
                      bot.process.stateType == ProcessStateType.Done // Part of cancelling step
            },

            State {
                name: "printing"
                extend: "running"
                when: bot.process.stateType == ProcessStateType.Printing
            },

            State {
                name: "print_paused"
                extend: "paused"
                when: bot.process.stateType == ProcessStateType.Paused
            },

            State {
                name: "print_completed"
                extend: "success"
                when: bot.process.stateType == ProcessStateType.Completed
            },

            State {
                name: "print_failed"
                extend: "alert"
                when: bot.process.stateType == ProcessStateType.Failed ||
                      bot.process.stateType == ProcessStateType.Cancelled
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
