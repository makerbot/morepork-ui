import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: advancedInfo
    width: 800
    height: 440
    smooth: false

    RoundedButton {
        id: roundedButton
        x: 645
        y: 288
        buttonWidth: 120
        buttonHeight: 120
        button_text.visible: false
        Image {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/refresh.png"
            width: sourceSize.width
            height: sourceSize.height
        }

        button_mouseArea.onClicked: {
            bot.query_status()
        }

        button_mouseArea.onPressed: {
            img.source = "qrc:/img/refresh_black.png"
        }

        button_mouseArea.onReleased: {
            img.source = "qrc:/img/refresh.png"
        }

    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Item {
        id: base
        anchors.fill: parent

        Item {
            id: chamber
            x: 383
            y: 206
            width: 200
            height: 200

            Text {
                id: text1
                y: 8
                color: "#ffffff"
                text: "CHAMBER"
                font.letterSpacing: 1
                font.bold: true
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15
            }

            RowLayout {
                id: rowLayout
                x: 14
                y: 18
                width: 200
                height: 150
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    id: columnLayout
                    width: 100
                    height: 150
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text {
                        id: text2
                        color: "#ffffff"
                        text: "CURRENT TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text3
                        color: "#ffffff"
                        text: "TARGET TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text4
                        color: "#ffffff"
                        text: "FAN A SPEED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text5
                        color: "#ffffff"
                        text: "FAN B SPEED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text6
                        color: "#ffffff"
                        text: "HEATER A TEMP"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text7
                        color: "#ffffff"
                        text: "HEATER B TEMP"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text8
                        color: "#ffffff"
                        text: "ERROR"
                        font.pixelSize: 12
                    }
                }

                ColumnLayout {
                    id: columnLayout1
                    width: 100
                    height: 150
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text {
                        id: text9
                        color: "#ffffff"
                        text: bot.infoChamberCurrentTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text10
                        color: "#ffffff"
                        text: bot.infoChamberTargetTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text11
                        color: "#ffffff"
                        text: bot.infoChamberFanASpeed
                        font.pixelSize: 12
                    }

                    Text {
                        id: text12
                        color: "#ffffff"
                        text: bot.infoChamberFanBSpeed
                        font.pixelSize: 12
                    }

                    Text {
                        id: text13
                        color: "#ffffff"
                        text: bot.infoChamberHeaterATemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text14
                        color: "#ffffff"
                        text: bot.infoChamberHeaterBTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text15
                        color: "#ffffff"
                        text: bot.infoChamberError
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item {
            id: axes
            x: 13
            y: 220
            width: 471
            height: 200

            Text {
                id: text78
                x: 150
                y: -6
                color: "#ffffff"
                text: "MOTION STATUS"
                font.letterSpacing: 1
                font.bold: true
                anchors.horizontalCenterOffset: -75
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15

                Text {
                    id: text86
                    x: -50
                    y: 29
                    color: "#ffffff"
                    text: "ENABLED"
                    font.letterSpacing: 1
                    font.bold: true
                    font.pixelSize: 12

                    ColumnLayout {
                        id: columnLayout11
                        x: 4
                        y: 21
                        width: 42
                        height: 139
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            id: text89
                            color: "#ffffff"
                            text: bot.infoAxisXEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text90
                            color: "#ffffff"
                            text: bot.infoAxisYEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text91
                            color: "#ffffff"
                            text: bot.infoAxisZEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text92
                            color: "#ffffff"
                            text: bot.infoAxisAEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text93
                            color: "#ffffff"
                            text: bot.infoAxisBEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text94
                            color: "#ffffff"
                            text: bot.infoAxisAAEnabled
                            font.pixelSize: 12
                        }

                        Text {
                            id: text95
                            color: "#ffffff"
                            text: bot.infoAxisBBEnabled
                            font.pixelSize: 12
                        }
                    }
                }

                Text {
                    id: text87
                    x: 30
                    y: 29
                    color: "#ffffff"
                    text: "ENDSTOP"
                    font.letterSpacing: 1
                    font.bold: true
                    font.pixelSize: 12

                    ColumnLayout {
                        id: columnLayout12
                        x: 23
                        y: 21
                        width: 42
                        height: 139
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            id: text96
                            color: "#ffffff"
                            text: bot.infoAxisXEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text97
                            color: "#ffffff"
                            text: bot.infoAxisYEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text98
                            color: "#ffffff"
                            text: bot.infoAxisZEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text99
                            color: "#ffffff"
                            text: bot.infoAxisAEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text100
                            color: "#ffffff"
                            text: bot.infoAxisBEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text101
                            color: "#ffffff"
                            text: bot.infoAxisAAEndStopActive
                            font.pixelSize: 12
                        }

                        Text {
                            id: text102
                            color: "#ffffff"
                            text: bot.infoAxisBBEndStopActive
                            font.pixelSize: 12
                        }
                    }
                }

                Text {
                    id: text88
                    x: 120
                    y: 29
                    color: "#ffffff"
                    text: "POSITION"
                    font.letterSpacing: 1
                    font.bold: true
                    font.pixelSize: 12

                    ColumnLayout {
                        id: columnLayout13
                        x: 0
                        y: 21
                        width: 42
                        height: 139
                        Text {
                            id: text103
                            color: "#ffffff"
                            text: bot.infoAxisXPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text104
                            color: "#ffffff"
                            text: bot.infoAxisYPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text105
                            color: "#ffffff"
                            text: bot.infoAxisZPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text106
                            color: "#ffffff"
                            text: bot.infoAxisAPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text107
                            color: "#ffffff"
                            text: bot.infoAxisBPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text108
                            color: "#ffffff"
                            text: bot.infoAxisAAPosition
                            font.pixelSize: 12
                        }

                        Text {
                            id: text109
                            color: "#ffffff"
                            text: bot.infoAxisBBPosition
                            font.pixelSize: 12
                        }
                    }
                }

                Text {
                    id: text115
                    x: -90
                    y: 29
                    color: "#ffffff"
                    text: "AXIS"
                    font.letterSpacing: 1
                    font.bold: true
                    font.pixelSize: 12

                    ColumnLayout {
                        id: columnLayout10
                        x: 0
                        y: 21
                        width: 16
                        height: 139
                        anchors.horizontalCenterOffset: 0
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: text85
                            color: "#ffffff"
                            text: "X"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text84
                            color: "#ffffff"
                            text: "Y"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text83
                            color: "#ffffff"
                            text: "Z"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text82
                            color: "#ffffff"
                            text: "A"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text81
                            color: "#ffffff"
                            text: "B"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text80
                            color: "#ffffff"
                            text: "AA"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }

                        Text {
                            id: text79
                            color: "#ffffff"
                            text: "BB"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 12
                        }






                    }
                }
            }
        }

        Item {
            id: toolheads
            x: 12
            y: -5
            width: 320
            height: 200

            Text {
                id: text16
                y: 0
                color: "#ffffff"
                text: "TOOLHEADS"
                font.letterSpacing: 1
                font.bold: true
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15

                Text {
                    id: text32
                    x: -54
                    y: 25
                    color: "#ffffff"
                    text: "A/1"
                    font.letterSpacing: 1
                    font.bold: true
                    anchors.horizontalCenterOffset: -100
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                }

                Text {
                    id: text31
                    x: 123
                    y: 25
                    color: "#ffffff"
                    text: "B/2"
                    font.letterSpacing: 1
                    font.bold: true
                    anchors.horizontalCenterOffset: 100
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                }

            }

            RowLayout {
                id: rowLayout1
                x: -1
                y: 40
                width: 162
                height: 160
                spacing: 10
                anchors.horizontalCenterOffset: -75
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    id: columnLayout2
                    width: 100
                    height: 150
                    Text {
                        id: text17
                        color: "#ffffff"
                        text: "ATTACHED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text18
                        color: "#ffffff"
                        text: "FILAMENT PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text19
                        color: "#ffffff"
                        text: "JAM ENABLED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text20
                        color: "#ffffff"
                        text: "CURRENT TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text21
                        color: "#ffffff"
                        text: "TARGET TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text120
                        color: "#ffffff"
                        text: "ENCODER TICKS"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text22
                        color: "#ffffff"
                        text: "ACTIVE FAN RPM"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text23
                        color: "#ffffff"
                        text: "GRADIENT FAN RPM"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text33
                        color: "#ffffff"
                        text: "HES VALUE"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text116
                        color: "#ffffff"
                        text: "ERROR"
                        font.pixelSize: 12
                    }

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                ColumnLayout {
                    id: columnLayout3
                    width: 100
                    height: 150
                    Text {
                        id: text24
                        color: "#ffffff"
                        text: bot.infoToolheadAAttached
                        font.pixelSize: 12
                    }

                    Text {
                        id: text25
                        color: "#ffffff"
                        text: bot.infoToolheadAFilamentPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text26
                        color: "#ffffff"
                        text: bot.infoToolheadAFilamentJamEnabled
                        font.pixelSize: 12
                    }

                    Text {
                        id: text27
                        color: "#ffffff"
                        text: bot.infoToolheadACurrentTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text28
                        color: "#ffffff"
                        text: bot.infoToolheadATargetTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text121
                        color: "#ffffff"
                        text: bot.infoToolheadAEncoderTicks
                        font.pixelSize: 12
                    }

                    Text {
                        id: text29
                        color: "#ffffff"
                        text: bot.infoToolheadAActiveFanRPM
                        font.pixelSize: 12
                    }

                    Text {
                        id: text30
                        color: "#ffffff"
                        text: bot.infoToolheadAGradientFanRPM
                        font.pixelSize: 12
                    }

                    Text {
                        id: text34
                        color: "#ffffff"
                        text: bot.infoToolheadAHESValue
                        font.pixelSize: 12
                    }

                    Text {
                        id: text117
                        color: "#ffffff"
                        text: bot.infoToolheadAError
                        font.pixelSize: 12
                    }

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }

            RowLayout {
                id: rowLayout2
                x: 282
                y: 40
                width: 162
                height: 160
                spacing: 10
                ColumnLayout {
                    id: columnLayout4
                    width: 100
                    height: 150
                    Text {
                        id: text35
                        color: "#ffffff"
                        text: "ATTACHED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text36
                        color: "#ffffff"
                        text: "FILAMENT PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text37
                        color: "#ffffff"
                        text: "JAM ENABLED"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text38
                        color: "#ffffff"
                        text: "CURRENT TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text39
                        color: "#ffffff"
                        text: "TARGET TEMP."
                        font.pixelSize: 12
                    }

                    Text {
                        id: text122
                        color: "#ffffff"
                        text: "ENCODER TICKS"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text40
                        color: "#ffffff"
                        text: "ACTIVE FAN RPM"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text41
                        color: "#ffffff"
                        text: "GRADIENT FAN RPM"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text42
                        color: "#ffffff"
                        text: "HES VALUE"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text118
                        color: "#ffffff"
                        text: "ERROR"
                        font.pixelSize: 12
                    }

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                ColumnLayout {
                    id: columnLayout5
                    width: 100
                    height: 150
                    Text {
                        id: text43
                        color: "#ffffff"
                        text: bot.infoToolheadBAttached
                        font.pixelSize: 12
                    }

                    Text {
                        id: text44
                        color: "#ffffff"
                        text: bot.infoToolheadBFilamentPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text45
                        color: "#ffffff"
                        text: bot.infoToolheadBFilamentJamEnabled
                        font.pixelSize: 12
                    }

                    Text {
                        id: text46
                        color: "#ffffff"
                        text: bot.infoToolheadBCurrentTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text47
                        color: "#ffffff"
                        text: bot.infoToolheadBTargetTemp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text123
                        color: "#ffffff"
                        text: bot.infoToolheadBEncoderTicks
                        font.pixelSize: 12
                    }

                    Text {
                        id: text48
                        color: "#ffffff"
                        text: bot.infoToolheadBActiveFanRPM
                        font.pixelSize: 12
                    }

                    Text {
                        id: text49
                        color: "#ffffff"
                        text: bot.infoToolheadBGradientFanRPM
                        font.pixelSize: 12
                    }

                    Text {
                        id: text50
                        color: "#ffffff"
                        text: bot.infoToolheadBHESValue
                        font.pixelSize: 12
                    }

                    Text {
                        id: text119
                        color: "#ffffff"
                        text: bot.infoToolheadBError
                        font.pixelSize: 12
                    }

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 120
            }

        }

        Item {
            id: bays
            x: 464
            y: -5
            width: 300
            height: 200

            Text {
                id: text51
                y: 0
                color: "#ffffff"
                text: "FILAMENT BAY"
                font.letterSpacing: 1
                font.bold: true
                anchors.horizontalCenterOffset: 0
                Text {
                    id: text53
                    x: -100
                    y: 25
                    color: "#ffffff"
                    text: "BAY 1"
                    font.letterSpacing: 1
                    font.bold: true
                    anchors.horizontalCenterOffset: -110
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                }

                Text {
                    id: text52
                    x: 92
                    y: 25
                    color: "#ffffff"
                    text: "BAY 2"
                    font.letterSpacing: 1
                    font.bold: true
                    anchors.horizontalCenterOffset: 90
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                }

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15
            }

            RowLayout {
                id: rowLayout3
                x: 12
                y: 52
                width: 162
                height: 160
                spacing: 10
                ColumnLayout {
                    id: columnLayout6
                    y: 11
                    width: 100
                    height: 140
                    Text {
                        id: text54
                        color: "#ffffff"
                        text: "TEMPERATURE"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text55
                        color: "#ffffff"
                        text: "HUMIDITY"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text56
                        color: "#ffffff"
                        text: "FILAMENT PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text57
                        color: "#ffffff"
                        text: "TAG PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text58
                        color: "#ffffff"
                        text: "TAG UID"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text59
                        color: "#ffffff"
                        text: "ERROR"
                        font.pixelSize: 12
                    }

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                }

                ColumnLayout {
                    id: columnLayout7
                    y: 11
                    width: 100
                    height: 140
                    Text {
                        id: text62
                        color: "#ffffff"
                        text: bot.infoBay1Temp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text63
                        color: "#ffffff"
                        text: bot.infoBay1Humidity
                        font.pixelSize: 12
                    }

                    Text {
                        id: text64
                        color: "#ffffff"
                        text: bot.infoBay1FilamentPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text65
                        color: "#ffffff"
                        text: bot.infoBay1TagPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text66
                        color: "#ffffff"
                        text: bot.infoBay1TagUID
                        font.pixelSize: 12
                    }

                    Text {
                        id: text67
                        color: "#ffffff"
                        text: bot.infoBay1Error
                        font.pixelSize: 12
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                }
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -120
            }

            RowLayout {
                id: rowLayout4
                x: 0
                y: 52
                width: 162
                height: 160
                spacing: 10
                ColumnLayout {
                    id: columnLayout8
                    y: 11
                    width: 100
                    height: 140
                    Text {
                        id: text60
                        color: "#ffffff"
                        text: "TEMPERATURE"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text61
                        color: "#ffffff"
                        text: "HUMIDITY"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text68
                        color: "#ffffff"
                        text: "FILAMENT PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text69
                        color: "#ffffff"
                        text: "TAG PRESENT"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text70
                        color: "#ffffff"
                        text: "TAG UID"
                        font.pixelSize: 12
                    }

                    Text {
                        id: text71
                        color: "#ffffff"
                        text: "ERROR"
                        font.pixelSize: 12
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                }

                ColumnLayout {
                    id: columnLayout9
                    y: 11
                    width: 100
                    height: 140
                    Text {
                        id: text72
                        color: "#ffffff"
                        text: bot.infoBay2Temp
                        font.pixelSize: 12
                    }

                    Text {
                        id: text73
                        color: "#ffffff"
                        text: bot.infoBay2Humidity
                        font.pixelSize: 12
                    }

                    Text {
                        id: text74
                        color: "#ffffff"
                        text: bot.infoBay2FilamentPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text75
                        color: "#ffffff"
                        text: bot.infoBay2TagPresent
                        font.pixelSize: 12
                    }

                    Text {
                        id: text76
                        color: "#ffffff"
                        text: bot.infoBay2TagUID
                        font.pixelSize: 12
                    }

                    Text {
                        id: text77
                        color: "#ffffff"
                        text: bot.infoBay2Error
                        font.pixelSize: 12
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                }
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 75
            }

        }

        Item {
            id: misc
            x: 645
            y: 205
            width: 112
            height: 109

            Text {
                id: text110
                y: 8
                color: "#ffffff"
                text: "MISC."
                font.letterSpacing: 1
                font.bold: true
                anchors.horizontalCenterOffset: 2
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 15
            }

            ColumnLayout {
                id: columnLayout14
                x: -3
                y: 36
                width: 76
                height: 40

                Text {
                    id: text111
                    color: "#ffffff"
                    text: "DOOR ACTIVATED"
                    font.pixelSize: 12
                }

                Text {
                    id: text112
                    color: "#ffffff"
                    text: "LID ACTIVATED"
                    font.pixelSize: 12
                }
            }

            ColumnLayout {
                id: columnLayout15
                x: 116
                y: 36
                width: 100
                height: 40

                Text {
                    id: text113
                    color: "#ffffff"
                    text: bot.infoDoorActivated
                    font.pixelSize: 12
                }

                Text {
                    id: text114
                    color: "#ffffff"
                    text: bot.infoLidActivated
                    font.pixelSize: 12
                }
            }
        }
    }
}
