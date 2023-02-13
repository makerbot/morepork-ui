import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "StartPrintSpecialInstructions"
    id: mainItem
    anchors.fill: parent

    property alias nextButton: nextButton
    property alias dontShowButton: dontShowButton
    property bool acknowledged: false
    visible: {
        if(acknowledged) {
            false
        } else {
            settings.getShowApplyGlueOnBuildPlateTip(print_model_material)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
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

    ColumnLayout {
        id: instructionsContainer
        height: 330
        width: 360
        anchors.left: image.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        TextHeadline {
            id: title_text
            text: "TITLE"
            font.weight: Font.Bold
        }

        TextBody {
            id: description_text
            text: "Description"
            font.weight: Font.Light
        }

        ColumnLayout {
            spacing: 20

            ButtonRectanglePrimary {
                id: nextButton
                text: qsTr("CONTINUE")
            }

            ButtonRectangleSecondary {
                id: dontShowButton
                text: qsTr("DON'T SHOW ME AGAIN")
            }
        }
    }

    states: [
        State {
            name: "apply_glue_to_bp"
            when: print_model_material == "nylon-cf" ||
                  print_model_material == "nylon12-cf" ||
                  print_model_material == "pet"

            PropertyChanges {
                target: title_text
                text: qsTr("APPLY GLUE TO THE BUILD PLATE")
            }

            PropertyChanges {
                target: description_text
                text: qsTr("Apply a thin coat of glue using the stick included with the material. Reapply a small layer of glue after each print is complete for best results.")
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/apply_glue_build_plate.png"
            }
        }
    ]
}
