import QtQuick 2.12
import QtQuick.Layouts 1.12

LoggingItem {
    property bool valueChanged: false
    property double currentOffsetCompensation: bot.offsetCompensationZ
    property double adjustedOffsetCompensation: currentOffsetCompensation
    property double offsetCompDiff: 0.0
    property double compensatedOffsetAZ: 0.0
    property double compensatedOffsetBZ: 0.0

    onValueChangedChanged: {
        if(valueChanged) {
            adjustedOffsetCompensation = currentOffsetCompensation
        }
    }

    Item {
        id: contentLeftSide
        width: parent.width/2
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0

        RowLayout {
            width: children.width
            height: children.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            Item {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Image {
                    id: baseScale
                    height: sourceSize.height
                    width: sourceSize.width
                    source: "qrc:/img/z_offset_scale.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    id: indicatorNeedle
                    height: sourceSize.height
                    width: sourceSize.width
                    source: "qrc:/img/current_z_offset_indicator.png"
                    anchors.horizontalCenter: baseScale.horizontalCenter
                    anchors.verticalCenter: baseScale.verticalCenter
                    anchors.verticalCenterOffset: {
                        -Math.min(Math.max(parseInt((valueChanged ? adjustedOffsetCompensation.toFixed(2) : currentOffsetCompensation.toFixed(2)) * 100 * 3), -baseScale.height/2), baseScale.height/2)
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 30

                Image {
                    id: increaseOffset
                    source: "qrc:/img/vector_image.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: sourceSize.width
                    Layout.preferredHeight: sourceSize.height

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            valueChanged = true
                            adjustedOffsetCompensation += 0.01
                        }
                    }
                    enabled: adjustedOffsetCompensation < 0.5
                    opacity: enabled ? 1 : 0.3
                }

                TextHeadline {
                    style: TextHeadline.Large
                    text: {
                        if(valueChanged) {
                            adjustedOffsetCompensation.toFixed(2) > 0 ?
                                  "+" + adjustedOffsetCompensation.toFixed(2) :
                                  adjustedOffsetCompensation.toFixed(2)
                        } else {
                            currentOffsetCompensation.toFixed(2) > 0 ?
                                  "+" + currentOffsetCompensation.toFixed(2) :
                                  currentOffsetCompensation.toFixed(2)
                        }
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Image {
                    id: decreaseOffset
                    source: "qrc:/img/vector_image.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: sourceSize.width
                    Layout.preferredHeight: sourceSize.height
                    rotation: 180

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            valueChanged = true
                            adjustedOffsetCompensation -= 0.01
                        }
                    }

                    enabled: adjustedOffsetCompensation > -0.5
                    opacity: enabled ? 1 : 0.3
                }
            }
        }
    }

    // This text will be removed after testing as having this in here will
    // make testing a lot easier.
    TextBody {
        id: text_back
        x: 471
        y: 373
        style: TextBody.Base
        width: 400
        text: bot.offsetAZ.toFixed(5) + "  " + bot.offsetBZ.toFixed(5)
        antialiasing: false
        smooth: false
        verticalAlignment: Text.AlignVCenter
    }

    ContentRightSide {
        textHeader {
            font.capitalization: Font.MixedCase
            text: qsTr("Z-OFFSET (VALUE IN mm)")
            visible: true
        }

        textBody {
            text: qsTr("Adjust the offset of your extruders relative to the build plate." +
                       "Please note that these values are reset whenever calibration or " +
                       "new extruders are added.")
            visible: true
        }

        buttonPrimary {
            text: qsTr("ENTER")
            visible: true
            onClicked: {
                offsetCompDiff = adjustedOffsetCompensation - currentOffsetCompensation
                compensatedOffsetAZ = parseFloat(bot.offsetAZ) + parseFloat(offsetCompDiff.toFixed(2))
                compensatedOffsetBZ = parseFloat(bot.offsetBZ) + parseFloat(offsetCompDiff.toFixed(2))
                bot.setBuildPlateZeroZOffset(compensatedOffsetAZ, compensatedOffsetBZ)
                bot.setCalibrationOffsetsCompensation(0,0,adjustedOffsetCompensation.toFixed(2))
                bot.get_calibration_offsets()
                bot.getCalibrationOffsetsCompensation()
                delayedResetValueChanged.start()
            }
            enabled: valueChanged
        }

        buttonSecondary1 {
            text: qsTr("RESET")
            visible: true
            onClicked: {
                resetOffsetCompensationChangesPopup.open()
            }
            enabled: valueChanged
        }
        visible: true
    }

    // I hate to do this. The valueChanged flag is used to determine whether the
    // indicator needle shows the last compensation value or the value the user is
    // currently changing to. When we set the modified value as the saved value we
    // immediately reset this flag to show the saved value but there is a delay where
    // the needle jumps to the last saved value before finally going to the most recent
    // saved value. This timer delays going back to the saved value by enough time that
    // it has the most recent value.
    Timer {
        id: delayedResetValueChanged
        interval: 1000
        onTriggered: {
            valueChanged = false
        }
    }

    CustomPopup {
        popupName: "ResetOffsetCompensationChangesPopup"
        id: resetOffsetCompensationChangesPopup
        popupHeight: 250
        showTwoButtons: true

        leftButton.onClicked: {
            resetOffsetCompensationChangesPopup.close()
        }
        leftButtonText: qsTr("BACK")

        rightButton.onClicked: {
            // This is called reset but we actually only reset to the last saved
            // compensation value and dont actaully reset the values to zero.
            bot.getCalibrationOffsetsCompensation()
            resetOffsetCompensationChangesPopup.close()
            valueChanged = false
        }
        rightButtonText: qsTr("CONFIRM")

        ColumnLayout {
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 140
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                source: "qrc:/img/process_error_small.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                text: qsTr("Discard Changes?")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
