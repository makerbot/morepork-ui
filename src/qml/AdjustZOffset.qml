import QtQuick 2.12
import QtQuick.Layouts 1.12

LoggingItem {
    property bool valueChanged: false
    property double lastAutoCalAZOffset: bot.lastAutoCalOffsetAZ
    property double lastAutoCalBZOffset: bot.lastAutoCalOffsetBZ
    property double currentAZOffset: bot.offsetAZ
    property double currentBZOffset: bot.offsetBZ
    property double adjustedAZOffset: 0.0
    property double adjustedBZOffset: 0.0
    property double offsetDiff: valueChanged ?
                                    lastAutoCalAZOffset - adjustedAZOffset :
                                    lastAutoCalAZOffset - currentAZOffset

    onValueChangedChanged: {
        if(valueChanged) {
            adjustedAZOffset = currentAZOffset
            adjustedBZOffset = currentBZOffset
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
            spacing: -20

            Item {
                id: offsetAdjusterImageItem
                Layout.preferredWidth: 200
                Layout.preferredHeight: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Image {
                    id: nozzleImage
                    z: 2
                    height: sourceSize.height
                    width: sourceSize.width
                    source: "qrc:/img/z_offset_nozzle.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: buildPlateImage.top
                    anchors.bottomMargin: 10 + (offsetDiff.toFixed(2) * 100 * 1.5)
                }

                Image {
                    id: buildPlateImage
                    z: 1
                    height: sourceSize.height
                    width: sourceSize.width
                    source: "qrc:/img/z_offset_build_plate.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 80
                    anchors.bottom: parent.bottom
                }
            }

            ColumnLayout {
                id: offsetAdjusterNumberItem
                Layout.preferredWidth: 200
                Layout.preferredHeight: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 30

                Image {
                    id: increasExtruderToBPDistance
                    source: "qrc:/img/vector_image.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: sourceSize.width
                    Layout.preferredHeight: sourceSize.height

                    MouseArea {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width + 100
                        height: parent.height + 100
                        onClicked: {
                            valueChanged = true
                            adjustedAZOffset -= 0.01
                            adjustedBZOffset -= 0.01
                            // Mark that no adjustment has been made which will disable
                            // the reset button if the user adjusts the compensation
                            // slider to the existing value
                            if(adjustedAZOffset.toFixed(3) == currentAZOffset.toFixed(3) &&
                               adjustedBZOffset.toFixed(3) == currentBZOffset.toFixed(3)) {
                               valueChanged = false
                            }
                        }
                    }
                    enabled: offsetDiff.toFixed(2) < 0.5
                    opacity: enabled ? 1 : 0.3
                }

                TextHeadline {
                    style: TextHeadline.Large
                    text: {
                        offsetDiff > 0 ?
                            "+" + offsetDiff.toFixed(2) :
                            offsetDiff.toFixed(2)
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Image {
                    id: decreaseExtruderToBPDistance
                    source: "qrc:/img/vector_image.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: sourceSize.width
                    Layout.preferredHeight: sourceSize.height
                    rotation: 180

                    MouseArea {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width + 100
                        height: parent.height + 100
                        onClicked: {
                            valueChanged = true
                            adjustedAZOffset += 0.01
                            adjustedBZOffset += 0.01
                            // Mark that no adjustment has been made which will disable
                            // the reset button if the user adjusts the compensation
                            // slider to the existing value
                            if(adjustedAZOffset.toFixed(3) == currentAZOffset.toFixed(3) &&
                               adjustedBZOffset.toFixed(3) == currentBZOffset.toFixed(3)) {
                               valueChanged = false
                            }
                        }
                    }

                    enabled: offsetDiff.toFixed(2) > -0.5
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
            text: qsTr("Adjust the offset of your extruders relative to the build plate. Please " +
                       "note that these values are reset whenever automatic calibration is run.")
            visible: true
        }

        buttonPrimary {
            text: qsTr("ENTER")
            visible: true
            onClicked: {
                bot.setBuildPlateZeroZOffset(adjustedAZOffset, adjustedBZOffset)
                bot.get_calibration_offsets()
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
    // indicator needle shows the last compensation value (difference of the current
    // from the last auto cal attempt) or the value the user is currently changing to
    // (difference between the adjusted from the last auto cal attempt). When we set
    // the adjusted value as the current value we immediately reset this flag to show
    // the compensation from the just updated current to the last auto cal attempt value
    // but there is a delay where the needle jumps to the previous compensation value
    // before finally going to the most recent compensation value. This timer delays
    // ensure that the current offsets are updated with the updated offsets that the
    // user just set before showing the compensation value.
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
            valueChanged = false
            resetOffsetCompensationChangesPopup.close()
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
