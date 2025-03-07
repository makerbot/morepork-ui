import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0

Item {
    anchors.fill: parent

    property int baseTemperature: {
        if(bot.extruderAType == ExtruderType.MK14_EXP) {
            160 // Range -- 160-300
        } else if(bot.extruderAType == ExtruderType.MK14_HOT_E) {
            300 // Range -- 300-370
        } else {
            0
        }
    }

    property alias setTempButton: setTempButton
    property alias temperatureTumbler: temperatureTumbler

    function formatText(modelData) {
        return ((baseTemperature + modelData*5).toString())
    }

    Component {
        id: delegateComponent

        Text {
            text: formatText(modelData)
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 175
            font.weight: Font.Light
            font.family: defaultFont.name
            color: "#ffffff"
        }
    }

    Row {
        id: row
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Tumbler {
            id: temperatureTumbler
            width: 400
            height: 500
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: {
                if(bot.extruderAType == ExtruderType.MK14_EXP) {
                    29
                } else if(bot.extruderAType == ExtruderType.MK14_HOT_E) {
                    15
                } else {
                    1
                }
            }
            delegate: delegateComponent

            Text {
                text: "°C"
                color: "#ffffff"
                font.family: defaultFont.name
                font.weight: Font.Light
                font.pointSize: 20
                font.letterSpacing: 2
                anchors.top: parent.top
                anchors.topMargin: 172
                anchors.left: parent.right
                anchors.leftMargin: -20
            }
        }
    }

    Item {
        id: overlayItem
        width: 500
        height: 175
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10

        Rectangle {
            id: topLine
            width: 350
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: bottomLine
            width: 350
            height: 1
            color: "#ffffff"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: topFadeItem
            width: 800
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#000000"
                }

                GradientStop {
                    position: 1
                    color: "#00000000"
                }
            }
            anchors.bottom: parent.top
            anchors.bottomMargin: 0
        }

        Rectangle {
            id: bottomFadeItem
            width: 800
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#00000000"
                }

                GradientStop {
                    position: 1
                    color: "#000000"
                }
            }
            anchors.top: parent.bottom
            anchors.topMargin: 0
        }
    }

    RoundedButton {
        id: setTempButton
        buttonHeight: 50
        buttonWidth: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        label: isLoadFilament ? qsTr("LOAD") : qsTr("UNLOAD")
        opacity: {
            button_mouseArea.enabled ? 1.0 : 0.1
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }

        button_mouseArea {
            onClicked: {
                var temp = temperatureTumbler.currentItem.text
                startLoadUnloadCustomTemperature(toolIdx, parseInt(temp, 10))
            }
            enabled: {
                !temperatureTumbler.moving
            }
        }
    }
}
