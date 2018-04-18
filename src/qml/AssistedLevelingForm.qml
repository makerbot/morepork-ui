import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

Item {
    id: assistedLevelingPage
    width: 800
    height: 440
    smooth: false
    property int currentHES
    property int targetHESUpper
    property int targetHESLower

    Rectangle {
        id: rectangle
        color: "#000000"
        anchors.fill: parent
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/sombrero_build_plate.png"
        visible: true

        Item {
            id: item1
            width: 400
            height: 250
            anchors.left: parent.right
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: title
                width: 252
                text: "LEVEL         BUILD PLATE"
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: "#e6e6e6"
                font.family: "Antennae"
                font.pixelSize: 30
                font.weight: Font.Bold
                lineHeight: 1.35
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
                font.family: "Antennae"
                font.pixelSize: 18
                font.weight: Font.Light
                text: "Assisted leveling will check your build plate and prompt you to make any adjustments"
                lineHeight: 1.2
            }

            RoundedButton {
                id: button
                label: "BEGIN LEVELING"
                buttonWidth: 260
                buttonHeight: 50
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: subtitle.bottom
                anchors.topMargin: 20
                button_mouseArea.onClicked: {
                    bot.assistedLevel()
                }
            }
        }
    }


    //    Text {
    //        color: "#ffffff"
    //        text: "Bot Not in Assisted Leveling Process"
    //        anchors.horizontalCenter: parent.horizontalCenter
    //        anchors.verticalCenter: parent.verticalCenter
    //        visible: bot.process.type != ProcessType.AssistedLeveling
    //        antialiasing: false
    //        smooth: false
    //        font.letterSpacing: 3
    //        font.family: "Antenna"
    //        font.weight: Font.Light
    //        font.pixelSize: 21
    //    }

    //    ColumnLayout {
    //        id: columnLayout
    //        anchors.top: parent.top
    //        anchors.topMargin: 35
    //        anchors.horizontalCenter: parent.horizontalCenter
    //        visible: bot.process.type == ProcessType.AssistedLeveling

    //        Text {
    //            id: text5
    //            color: "#ffffff"
    //            text: "Step: " + bot.process.stepStr
    //            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    //            antialiasing: false
    //            smooth: false
    //            font.letterSpacing: 3
    //            font.family: "Antenna"
    //            font.weight: Font.Light
    //            font.pixelSize: 21
    //        }

    //        Text {
    //            id: text1
    //            color: "#ffffff"
    //            text: "Current HES: " + bot.process.currentHes
    //            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    //            antialiasing: false
    //            smooth: false
    //            font.letterSpacing: 3
    //            font.family: "Antenna"
    //            font.weight: Font.Light
    //            font.pixelSize: 21
    //        }

    //        Text {
    //            id: text2
    //            color: "#ffffff"
    //            text: "Target HES Upper: " + bot.process.targetHesUpper
    //            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    //            antialiasing: false
    //            smooth: false
    //            font.letterSpacing: 3
    //            font.family: "Antenna"
    //            font.weight: Font.Light
    //            font.pixelSize: 21
    //        }

    //        Text {
    //            id: text3
    //            color: "#ffffff"
    //            text: "Target HES Lower: " + bot.process.targetHesLower
    //            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    //            antialiasing: false
    //            smooth: false
    //            font.letterSpacing: 3
    //            font.family: "Antenna"
    //            font.weight: Font.Light
    //            font.pixelSize: 21
    //        }

    //        Text {
    //            id: text4
    //            color: "#ffffff"
    //            text: {
    //                switch(bot.process.levelState)
    //                {
    //                case 1:
    //                    "Level State: LOW"
    //                    break;
    //                case 2:
    //                    "Level State: HIGH"
    //                    break;
    //                case 3:
    //                    "Level State: OK"
    //                    break;
    //                default:
    //                    "Level State: " + bot.process.levelState
    //                    break;
    //                }
    //            }
    //            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    //            antialiasing: false
    //            smooth: false
    //            font.letterSpacing: 3
    //            font.family: "Antenna"
    //            font.weight: Font.Light
    //            font.pixelSize: 21
    //        }
    //    }

    LoadingIcon {
        id: loadingIcon
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        loading: visible
        visible: false

        Text {
            id: processText
            text: "DEFAULT"
            anchors.left: parent.right
            anchors.leftMargin: 100
            anchors.verticalCenter: parent.verticalCenter
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 18
            font.weight: Font.Bold
            lineHeight: 1.3
        }

    }

    Image {
        id: levelingDirections
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: leveling_instruction
            text: "Text"
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 18
            font.weight: Font.Light
        }

        Image {
            id: level
            width: 1600
            height: 104
            anchors.top: parent.bottom
            anchors.topMargin: 50
            visible: false
            smooth: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset:
                currentHES - (targetHESLower + targetHESUpper)/2
            source:
                if(currentHES == 0) {
                    "qrc:/img/build_plate_level_begin.png"
                }
                else if(currentHES < targetHESUpper && currentHES > targetHESLower) {
                    "qrc:/img/build_plate_level.png"
                }
                else {
                    "qrc:/img/build_plate_not_level.png"
                }
        }

        Image {
            id: range
            x: 0
            y: 150
            visible: false
            width: sourceSize.width
            height: sourceSize.height
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 120
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/build_plate_level_range.png"
        }

        RoundedButton {
            id: acknowledgeLevel
            x: -75
            y: 175
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 45
            anchors.horizontalCenter: parent.horizontalCenter
            disable_button: ((currentHES < targetHESUpper) &&
                             (currentHES > targetHESLower)) ? false : true
            buttonWidth: 150
            buttonHeight: 50
            label: "LEVELED"
            visible: false
            opacity: disable_button ? 0.4 : 1
            button_mouseArea.onClicked: {
                if(!disable_button) {
                    bot.acknowledge_level()
                }
            }
        }


    }


}
