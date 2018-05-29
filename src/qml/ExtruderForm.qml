import QtQuick 2.4
import QtQuick.Layouts 1.3

Item {
    id: extruder
    width: 400
    height: 420
    smooth: false
    antialiasing: false
    property bool extruderPresent
    property bool filamentPresent
    property int extruderID
    property int extruderTemperature
    property string extruderUsage
    property string extruderSerialNo
    property int filamentColor
    property string filamentColorText: "COLOR"
    property alias extruder_image: extruder_image

    Rectangle {
        id: filament_rectangle
        anchors.bottom: extruder_image.top
        anchors.bottomMargin: 0
        anchors.horizontalCenter: extruder_image.horizontalCenter
        anchors.horizontalCenterOffset: -8
        width: 6
        height: 25
        color: "#ffffff"
        visible: filamentPresent
    }

    Image {
        id: extruder_image
        width: 86
        height: 382
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 5
        anchors.left: parent.left
        anchors.leftMargin: 50
        source: extruderPresent ? "qrc:/img/extruder_attached.png" :
                                  "qrc:/img/extruder_not_attached.png"

        Item {
            id: item1
            width: 200
            height: parent.height
            anchors.left: parent.right
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: extruderID_text
                text: extruderID
                anchors.top: parent.top
                anchors.topMargin: 20
                antialiasing: false
                smooth: false
                color: "#ffffff"
                font.family: "Antenna"
                font.weight: Font.Bold
                font.pixelSize: 35
            }

            Text {
                id: extruderType_text
                width: 180
                anchors.top: extruderID_text.bottom
                anchors.topMargin: 10
                text: {
                    if(extruderPresent)
                    {
                        switch(extruderID) {
                        case 1:
                            "SUPPORT EXTRUDER"
                            break;
                        case 2:
                            "MATERIAL EXTRUDER"
                            break;
                        }
                    }
                    else {
                        "NO EXTRUDER DETECTED"
                    }
                }
                lineHeight: 1.2
                wrapMode: Text.WordWrap
                font.letterSpacing: 3
                antialiasing: false
                smooth: false
                color: "#ffffff"
                font.family: "Antenna"
                font.weight: Font.Bold
                font.pixelSize: 16
            }

            RoundedButton {
                id: attachButton
                anchors.top: extruderType_text.bottom
                anchors.topMargin: 20
                buttonHeight: 42
                buttonWidth: 130
                label: "ATTACH"
                label_size: 18
                visible: !extruderPresent
                button_mouseArea.onClicked: {
                    itemAttachExtruder.extruder = extruderID
                    extruderSwipeView.swipeToItem(1)
                }
            }

            RowLayout {
                id: extruderDetails
                anchors.top: extruderType_text.bottom
                anchors.topMargin: 20
                spacing: 10
                visible: extruderPresent
                Text {
                    id: filamentMaterial_text
                    text: {
                        switch(extruderID) {
                        case 1:
                            "PVA"
                            break;
                        case 2:
                            "PLA"
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    color: "#ffffff"
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 16
                }

                Rectangle {
                    id: divider
                    color: "#ffffff"
                    width: 1
                    height: 18
                }

                Text {
                    id: filamentMaterialColor_text
                    text: filamentColorText
                    antialiasing: false
                    smooth: false
                    color: "#ffffff"
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 16
                }

            }

            Item {
                id: extruderStats
                anchors.top: extruderPresent ? extruderDetails.bottom :
                                               attachButton.bottom
                anchors.topMargin: extruderPresent ? 25 : 1
                width: 135
                height: 100
                opacity: !extruderPresent ? 0.4 : 1

                ColumnLayout {
                    id: columnLayout
                    width: 100
                    height: 65
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 9

                    Text {
                        id: temperature_label
                        text: "TEMPERATURE"
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: usage_label
                        text: "USAGE"
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: serial_label
                        text: "SERIAL #"
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }
                }

                ColumnLayout {
                    id: columnLayout1
                    width: 30
                    height: 65
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 9

                    Text {
                        id: temperature_text
                        text: extruderTemperature + "C"
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: usage_text
                        text: extruderUsage
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: serial_text
                        text: extruderSerialNo
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }
                }
            }

            RoundedButton {
                id: materialButton
                anchors.top: extruderStats.bottom
                anchors.topMargin: 10
                buttonHeight: 42
                buttonWidth: 160
                label: "MATERIAL"
                label_size: 18
                disable_button: !extruderPresent
                opacity: !extruderPresent ? 0.4 : 1
                button_mouseArea.onClicked: {
                    if(!disable_button)
                        mainSwipeView.swipeToItem(5)
                }
            }
        }
    }
}
