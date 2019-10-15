import QtQuick 2.10
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ExtruderTypeEnum 1.0

Item {
    id: extruder
    width: 400
    height: 420
    smooth: false
    antialiasing: false
    property int extruderID
    property string extruderSerialNo
    property alias extruder_image: extruder_image
    property alias attachButton: attachButton
    property alias detachButton: detachButton

    property string idxAsAxis: {
        switch (extruderID) {
            case 1:
                "A";
                break;
            case 2:
                "B";
                break;
            default:
                "A";
        }
    }

    property bool extruderPresent:  bot["extruder%1Present".arg(idxAsAxis)]
    property bool filamentPresent:  bot["extruder%1FilamentPresent".arg(idxAsAxis)]
    property int extruderTemperature:  bot["extruder%1CurrentTemp".arg(idxAsAxis)]
    property string extruderUsage: bot["extruder%1ExtrusionDistance".arg(idxAsAxis)]

    property bool spoolPresent: {
        switch(extruderID) {
        case 1:
            materialPage.bay1.spoolPresent
            break;
        case 2:
            materialPage.bay2.spoolPresent
            break;
        }
    }

    onVisibleChanged: {
        if (visible) {
            bot.getToolStats(extruderID - 1);
        }
    }

    Rectangle {
        id: filament_rectangle
        anchors.bottom: extruder_image.top
        anchors.bottomMargin: 0
        anchors.horizontalCenter: extruder_image.horizontalCenter
        anchors.horizontalCenterOffset: -8
        width: 6
        height: 50
        color: "#ffffff"
        visible: extruderPresent && filamentPresent
    }

    Image {
        id: extruder_image
        width: 83
        height: 360
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 12
        anchors.left: parent.left
        anchors.leftMargin: 50
        source: {
            if(extruderPresent) {
                switch(extruderID) {
                case 1:
                    switch(bot.extruderAType) {
                        case ExtruderType.MK14:
                            "qrc:/img/extruder_1_attached.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/extruder_1XA_attached.png"
                            break;
                        case ExtruderType.MK14_EXP:
                            "qrc:/img/extruder_exp_attached.png"
                            break;
                    }
                    break;
                case 2:
                    switch(bot.extruderBType) {
                        case ExtruderType.MK14:
                            "qrc:/img/extruder_2_attached.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/extruder_2XA_attached.png"
                            break;
                    }
                    break;
                default:
                    "qrc:/img/extruder_not_attached.png"
                    break;
                }

            } else {
                "qrc:/img/extruder_not_attached.png"
            }
        }
        Item {
            id: item1
            width: 200
            height: parent.height
            anchors.left: parent.right
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: extruderID_text
                text: {
                    if(extruderPresent) {
                        switch(extruderID) {
                        case 1:
                            switch(bot.extruderAType) {
                            case ExtruderType.MK14:
                                "1A"
                                break;
                            case ExtruderType.MK14_HOT:
                                "1XA"
                                break;
                            case ExtruderType.MK14_EXP:
                                "LABS"
                            }
                            break;
                        case 2:
                            switch(bot.extruderBType) {
                            case ExtruderType.MK14:
                                "2A"
                                break;
                            case ExtruderType.MK14_HOT:
                                "2XA"
                                break;
                            }
                            break;
                        }
                    }
                    else {
                        extruderID
                    }
                }
                anchors.top: parent.top
                anchors.topMargin: -10
                antialiasing: false
                smooth: false
                color: "#ffffff"
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 36
                font.letterSpacing: 2
            }

            Text {
                id: extruderType_text
                width: 180
                anchors.top: extruderID_text.bottom
                anchors.topMargin: 15
                text: {
                    if(extruderPresent) {
                        switch(extruderID) {
                        case 1:
                            qsTr("MODEL EXTRUDER")
                            break;
                        case 2:
                            qsTr("SUPPORT EXTRUDER")
                            break;
                        }
                    }
                    else {
                        qsTr("NO EXTRUDER DETECTED")
                    }
                }
                lineHeight: 1.6
                wrapMode: Text.WordWrap
                font.letterSpacing: 3
                antialiasing: false
                smooth: false
                color: "#ffffff"
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 16
            }

            Item {
                id: extruderStats
                anchors.top: extruderType_text.bottom
                width: 135
                height: 45
                anchors.topMargin: 15
                opacity: !extruderPresent ? 0.4 : 1

                ColumnLayout {
                    id: columnLayout
                    width: 100
                    height: 40
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 9

                    Text {
                        id: temperature_label
                        text: qsTr("TEMPERATURE")
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: usage_label
                        text: qsTr("USAGE")
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }
                }

                ColumnLayout {
                    id: columnLayout1
                    width: 30
                    height: 40
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
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }

                    Text {
                        id: usage_text
                        text: extruderUsage + "mm"
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        antialiasing: false
                        smooth: false
                        color: "#cbcbcb"
                        font.letterSpacing: 2
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pixelSize: 13
                    }
                }
            }

            RoundedButton {
                id: detachButton
                anchors.top: extruderStats.bottom
                anchors.topMargin: 15
                label: qsTr("DETACH")
                visible: false
                buttonHeight: 46
                buttonWidth: 130
                label_size: 18
                disable_button: isProcessRunning()
            }

            RoundedButton {
                id: attachButton
                anchors.bottom: materialButton.top
                anchors.bottomMargin: 20
                buttonHeight: 46
                buttonWidth: 130
                label: qsTr("ATTACH")
                label_size: 18
                visible: !extruderPresent
            }

            RowLayout {
                id: extruderDetails
                anchors.bottom: materialButton.top
                anchors.bottomMargin: 20
                spacing: 10
                visible: extruderPresent
                Text {
                    id: filamentMaterial_text
                    Layout.maximumWidth: attachButton.width
                    elide: Text.ElideRight
                    maximumLineCount: 3
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: {
                        if(spoolPresent) {
                            switch(extruderID) {
                            case 1:
                                materialPage.bay1.filamentMaterialName + "\n" +
                                materialPage.bay1.filamentColorName
                                break;
                            case 2:
                                materialPage.bay2.filamentMaterialName + "\n" +
                                materialPage.bay2.filamentColorName
                                break;
                            }
                        }
                        else if(filamentPresent) {
                            qsTr("UNKNOWN\nMATERIAL")
                        }
                        else {
                            qsTr("NO MATERIAL")
                        }
                    }
                    font.capitalization: Font.AllUppercase
                    antialiasing: false
                    smooth: false
                    color: "#ffffff"
                    font.letterSpacing: 3
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 16
                    lineHeight: 1.6
                }
            }

            RoundedButton {
                id: materialButton
                anchors.top: extruderStats.bottom
                anchors.topMargin: 130
                buttonHeight: 46
                buttonWidth: 165
                label: qsTr("MATERIAL")
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
