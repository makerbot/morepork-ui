import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "AnnealPrint"
    id: annealPrintPage
    width: 800
    height: 420
    smooth: false
    antialiasing: false
    property alias actionButton: actionButton
    property real timeLeftHours: bot.process.timeRemaining/3600
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode !== 0

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.AnnealPrintProcess) {
            switch(currentStep) {
                case ProcessStateType.WaitingForPart:
                    state = "choose_material"
                    break;
                case ProcessStateType.Loading:
                case ProcessStateType.AnnealingPrint:
                    state = "annealing_print"
                    break;
                case ProcessStateType.Done:
                    if(state != "cancelling" &&
                       state != "annealing_failed" &&
                       state != "base state") {
                        state = "annealing_complete"
                    }
                    break;
                case ProcessStateType.Cancelling:
                    state = "cancelling"
                    break;
            }
        } else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                processDone()
            }
        }
    }

    onHasFailedChanged: {
        if(bot.process.type == ProcessType.AnnealPrintProcess) {
            state = "annealing_failed"
        }
    }

    property variant annealPartTemperatureListMethod : [
        {label: "nylon", temperature : 60, time : 10}
    ]

    property variant annealPartTemperatureListMethodX : [
        {label: "nylon", temperature : 80, time : 5}
    ]

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/anneal_print.png"
        opacity: 1.0
    }

    Item {
        id: mainItem
        width: 400
        height: 250
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: image.width
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -15
        opacity: 1.0

        Text {
            id: title
            width: 350
            text: qsTr("ANNEAL YOUR PRINT")
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 22
            font.weight: Font.Bold
            lineHeight: 1.2
            opacity: 1.0
        }

        Text {
            id: subtitle
            width: 350
            wrapMode: Text.WordWrap
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            text: qsTr("Annealing your print will remove any moisture and " +
                       "can enhance its mechanical properties. Remove the " +
                       "support material before annealing. " +
                       "Place your print in the build chamber. ")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("CHOOSE MATERIAL")
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            opacity: 1.0
        }

        ColumnLayout {
            id: status
            anchors.top: title.bottom
            anchors.topMargin: 10
            width: children.width
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 10
            opacity: 0

            Text {
                id: time_remaining_text
                text: "999"
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Text {
                id: chamber_temperature_text
                text: "999"
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -30
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    ListSelector {
        id: materialSelector
        model: {
            if(bot.machineType == MachineType.Fire) {
                annealPartTemperatureListMethod
            } else if(bot.machineType == MachineType.Lava) {
                annealPartTemperatureListMethodX
            } else if(bot.machineType == MachineType.Magma) {
                annealPartTemperatureListMethodX
            }
        }

        delegate:
            MaterialButton {
            id: materialButton
            materialNameText: model.modelData["label"]
            materialInfoText: {
                model.modelData["temperature"] + "°C | " + model.modelData["time"] + "HR"
            }
            onClicked: {
                bot.startAnnealing(parseInt(model.modelData["temperature"], 10), model.modelData["time"])
            }
        }
        visible: false
    }

    states: [
        State {
            name: "choose_material"

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }
        },
        State {
            name: "annealing_print"

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: {
                    if(bot.process.stateType == ProcessStateType.Loading) {
                        qsTr("HEATING CHAMBER")

                    } else if(bot.process.stateType == ProcessStateType.AnnealingPrint) {
                        qsTr("ANNEALING PRINT")
                    }
                }
                anchors.topMargin: 60
            }

            PropertyChanges {
                target: status
                opacity: 1
            }

            PropertyChanges {
                target: time_remaining_text
                visible: {
                    if(bot.process.stateType == ProcessStateType.Loading) {
                        false

                    } else if(bot.process.stateType == ProcessStateType.AnnealingPrint) {
                        true
                    }
                }
                text: {
                    (timeLeftHours < 1 ?
                         Math.round(timeLeftHours * 60) + "M " :
                         Math.round(timeLeftHours*10)/10 + "H ") +
                    qsTr("REMAINING")
                }
            }

            PropertyChanges {
                target: chamber_temperature_text
                text: bot.chamberCurrentTemp + "°C"
            }

            PropertyChanges {
                target: subtitle
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
                loadingProgress: bot.process.printPercentage
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "annealing_complete"

            PropertyChanges {
                target: image
                source: "qrc:/img/process_successful.png"
                anchors.leftMargin: 80
                opacity: 1
            }

            PropertyChanges {
                target: mainItem
                anchors.leftMargin: 420
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("ANNEALING COMPLETE")
                opacity: 1
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The print is now annealed and ready for use.")
                opacity: 1
            }

            PropertyChanges {
                target: actionButton
                opacity: 1
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("DONE")
            }
        },
        State {
            name: "annealing_failed"
            PropertyChanges {
                target: image
                source: "qrc:/img/error.png"
                opacity: 1
                anchors.leftMargin: 80
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
                anchors.leftMargin: 420
            }

            PropertyChanges {
                target: title
                text: qsTr("ANNEALING FAILED")
                opacity: 1
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                anchors.topMargin: -75
                opacity: 1
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("DONE")
            }
        },
        State {
            name: "cancelling"
            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
                anchors.leftMargin: 420
            }

            PropertyChanges {
                target: title
                text: qsTr("CANCELLING")
                opacity: 1
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Please wait.")
                opacity: 1
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                loadingProgress: 0
                visible: true
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        }
    ]
}
