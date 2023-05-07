import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "CleanExtrudersSequence"
    id: cleanExtrudersSequence
    width: 800
    height: 408

    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide

    ContentLeftSide {
        id: contentLeftSide
        animatedImage {
            source: "qrc:/img/scrub_nozzles.gif"
            visible: false
        }
        image {
            source: "qrc:/img/check_nozzles_clean.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        textHeader {
            text: qsTr("CLEAN EXTRUDER NOZZLES")
            visible: true
        }
        textBody {
            text: qsTr("Cleaning is not required the first time using the extruders. Otherwise, inspect the tips of the extruder for excess material.")
            visible: true
        }
        buttonPrimary {
            text: qsTr("CLEAN EXTRUDERS")
            visible: true
        }
        buttonSecondary1 {
            text: qsTr("SKIP")
            visible: true
        }
        temperatureStatus {
            visible: false
        }

        visible: true
    }

    states: [
        State {
            name: "check_nozzle_clean"
            when: enabled && bot.process.stateType == ProcessStateType.CheckNozzleClean

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                visible: false
            }
        },

        State {
            name: "heating_nozzle"
            when: enabled && bot.process.stateType == ProcessStateType.HeatingNozzle

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Loading
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("HEATING")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "clean_nozzle"
            when: enabled && bot.process.stateType == ProcessStateType.CleanNozzle

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CLEAN EXTRUDER NOZZLES")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Use the provided brush to clean the tips of the extruders for the most accurate calibration.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }


        },

        State {
            name: "finish_cleaning"
            when: enabled && bot.process.stateType == ProcessStateType.FinishCleaning
            extend: "clean_nozzle"
            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
            }
        },

        State {
            name: "cooling_nozzle"
            when: enabled && bot.process.stateType == ProcessStateType.CoolingNozzle
            extend: "heating_nozzle"

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("COOLING")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("The process will continue after the nozzles cool down.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                component1.customTargetTemperature: 50
                component2.customCurrentTemperature: 50
                visible: true
            }
        }
    ]
}
