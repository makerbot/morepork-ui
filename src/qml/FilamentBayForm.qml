import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: item2
    width: 800
    height: 180
    smooth: false
    antialiasing: false
    property int filamentBayID: 0
    property alias filamentMaterialType: materialIconLarge.filamentType
    property alias filamentMaterialColor: materialIconLarge.filamentColor
    property alias filamentMaterialPercent: materialIconLarge.filamentPercent
    property string filamentMaterialColorText: "COLOR"
    property string filamentMaterialQuantity: "-0.0"
    property alias loadButton: loadButton
    property alias unloadButton: unloadButton
    property alias switch1: switch1

    MaterialIcon {
        id: materialIconLarge
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false

        ColumnLayout {
            id: columnLayout
            width: 360
            height: 150
            anchors.left: parent.left
            anchors.leftMargin: 250
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            smooth: false
            antialiasing: false

            Text {
                id: filament_bay_text
                color: "#cbcbcb"
                text: "FILAMENT BAY " + filamentBayID
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                font.letterSpacing: 5
                font.family: "Antenna"
                font.weight: Font.Bold
                font.pixelSize: 20
                smooth: false
                antialiasing: false
            }

            RowLayout {
                id: rowLayout
                width: 300
                height: 25
                spacing: 10
                smooth: false
                antialiasing: false

                Text {
                    id: material_color_text
                    color: "#ffffff"
                    text: filamentMaterialColorText
                    font.letterSpacing: 4
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }

                Rectangle {
                    id: rectangle1
                    width: 1
                    height: 20
                    color: "#ffffff"
                    smooth: false
                    antialiasing: false
                }

                Text {
                    id: material_quantity_text
                    color: "#ffffff"
                    text: filamentMaterialQuantity +"KG" + " REMAINING"
                    font.letterSpacing: 4
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }
            }

            RowLayout {
                id: rowLayout2
                width: 300
                height: 25
                spacing: 10
                smooth: false
                antialiasing: false

                Text {
                    id: humidity_text
                    color: "#ffffff"
                    text: "HUMIDITY"
                    font.letterSpacing: 4
                    smooth: false
                    font.pixelSize: 18
                    font.weight: Font.Light
                    antialiasing: false
                    font.family: "Antenna"
                }

                Rectangle {
                    id: rectangle2
                    width: 1
                    height: 20
                    color: "#ffffff"
                    smooth: false
                    antialiasing: false
                }

                Image {
                    id: humidity_alert
                    height: 12
                    width: 12
                    antialiasing: false
                    smooth: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    source: "qrc:/img/check_mark_small.png"
                }
            }

            Item {
                id: item1
                width: 300
                height: 3
                visible: true
                smooth: false
                antialiasing: false
            }

            RowLayout {
                id: rowLayout1
                width: 300
                height: 60
                spacing: 30
                smooth: false
                antialiasing: false

                RoundedButton {
                    id: loadButton
                    buttonWidth: 120
                    buttonHeight: 50
                    label: "LOAD"
                }

                RoundedButton {
                    id: unloadButton
                    buttonWidth: 160
                    buttonHeight: 50
                    label: "UNLOAD"
                }
            }
        }
    }

    Switch {
        id: switch1
        checked: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 700

        Text {
            id: text1
            text: "Int."
            anchors.horizontalCenterOffset: -25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: switch1.bottom
            anchors.topMargin: 0
            color: "#ffffff"
            font.pixelSize: 15
            font.family: "Antennae"
        }

        Text {
            id: text2
            text: "Ext."
            anchors.horizontalCenterOffset: 25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: switch1.bottom
            anchors.topMargin: 0
            color: "#ffffff"
            font.pixelSize: 15
            font.family: "Antennae"
        }
    }
}
