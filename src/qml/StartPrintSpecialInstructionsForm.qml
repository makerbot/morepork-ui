import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "StartPrintSpecialInstructions"
    id: mainItem
    width: 800
    height: 440

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
        anchors.left: image.right
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            Layout.maximumWidth: 350
            color: "#cbcbcb"
            text: "TITLE"
            font.letterSpacing: 2
            font.wordSpacing: 3
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.pixelSize: 22
            font.weight: Font.Bold
            antialiasing: false
            smooth: false
            lineHeight: 1.2
        }

        Text {
            id: description_text
            Layout.maximumWidth: 350
            color: "#cbcbcb"
            text: "Description"
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.pixelSize: 20
            font.weight: Font.Light
            lineHeight: 1.2
            antialiasing: false
            smooth: false
        }

        RoundedButton {
            id: nextButton
            buttonHeight: 50
            label: qsTr("CONTINUE")
        }

        Item {
            id: emptySpacingItem
            height: 5
        }

        RoundedButton {
            id: dontShowButton
            buttonHeight: 50
            label: qsTr("DON'T SHOW ME AGAIN")
        }
    }
    states: [
        State {
            name: "apply_glue_to_bp"
            when: print_model_material == "nylon-cf" ||
                  print_model_material == "nylon-12-cf" ||
                  print_model_material == "petg"

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
