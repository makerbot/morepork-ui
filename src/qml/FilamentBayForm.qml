import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item2
    width: 800
    height: 180
    smooth: false
    antialiasing: false

    property int filamentBayID: 0
    property string filamentMaterial: "MAT"
    property string filamentMaterialColor: "COLOR"
    property string filamentQuantity: "-0.0"

    property alias loadButton: loadButton
    property alias unloadButton: unloadButton

    Rectangle {
        id: filament_color
        width: filament_image.width
        height: filament_image.height
        color: "#1a455c"
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: 65
        anchors.top: parent.top
        anchors.topMargin: 45
    }

    Image {
        id: filament_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 65
        anchors.top: parent.top
        anchors.topMargin: 45
        smooth: false
        antialiasing: false
        source: "qrc:/img/filamentbay_loaded.png"

        ColumnLayout {
            id: columnLayout
            width: 360
            height: 130
            anchors.top: parent.top
            anchors.topMargin: -45
            anchors.left: parent.left
            anchors.leftMargin: filament_image.width
            spacing: 5
            smooth: false
            antialiasing: false

            Text {
                id: filament_bay_text
                color: "#cbcbcb"
                text: "FILAMENT BAY " + filamentBayID
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                font.letterSpacing: 4
                font.family: "Antenna"
                font.weight: Font.Bold
                font.pixelSize: 21
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
                    id: material_text
                    color: "#cbcbcb"
                    text: filamentMaterial
                    font.letterSpacing: 2
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
                    visible: filamentMaterialColor != ""
                }

                Text {
                    id: material_color_text
                    color: "#cbcbcb"
                    text: filamentMaterialColor
                    font.letterSpacing: 2
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }

                Rectangle {
                    id: rectangle2
                    width: 1
                    height: 20
                    color: "#ffffff"
                    smooth: false
                    antialiasing: false
                    visible: filamentQuantity != "0"
                }

                Text {
                    id: material_quantity_text
                    color: "#cbcbcb"
                    text: filamentQuantity +"KG"
                    font.letterSpacing: 2
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }
            }

            Item {
                id: item1
                width: 300
                height: 10
                visible: true
                smooth: false
                antialiasing: false
            }

            RowLayout {
                id: rowLayout1
                width: 300
                height: 60
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                spacing: 30
                smooth: false
                antialiasing: false

                RoundedButton {
                    id: loadButton
                    buttonWidth: 120
                    buttonHeight: 40
                    label: "LOAD"
                }

                RoundedButton {
                    id: unloadButton
                    buttonWidth: 160
                    buttonHeight: 40
                    label: "UNLOAD"
                }
            }
        }
    }
}
