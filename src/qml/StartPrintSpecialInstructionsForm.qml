import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "StartPrintSpecialInstructions"
    id: mainItem
    anchors.fill: parent

    property alias nextButton: instructionsContainer.buttonPrimary
    property alias dontShowButton: instructionsContainer.buttonSecondary1
    property bool acknowledged: false
    visible:  {
        if(acknowledged) {
            false
        } else {
            settings.getShowApplyGlueOnBuildPlateTip(print_model_material)
        }
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/apply_glue_build_plate.png"
    }

    ContentRightSide {
        id: instructionsContainer

        textHeader {
            text: "TITLE"
            visible: true
        }
        textBody {
            text: "Descripton"
            visible: true
        }
        buttonPrimary {
            text: qsTr("CONTINUE")
            visible: true
        }
        buttonSecondary1 {
            text: qsTr("DON'T SHOW ME AGAIN")
            visible: true
        }
    }

    states: [
        State {
            name: "apply_glue_to_bp"
            when: print_model_material == "nylon-cf" ||
                  print_model_material == "nylon12-cf" ||
                  print_model_material == "pet"

            PropertyChanges {
                target: instructionsContainer
                textHeader.text: qsTr("APPLY GLUE TO THE BUILD PLATE")
                textBody.text: qsTr("Apply a thin coat of glue using the stick included with the material. Reapply a small layer of glue after each print is complete for best results.")
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/apply_glue_build_plate.png"
            }
        }
    ]
}
