import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: advancedInfo
    width: 800
    height: 440
    smooth: false

    RefreshButton {
        button_mouseArea.onClicked: {
            bot.query_status()
            bot.get_calibration_offsets()
        }
    }

    Flickable {
        id: flickableAdvancedInfo
        smooth: false
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.fill: parent
        contentHeight: columnContents.height

        Column {
            id: columnContents
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 50

            Item {
                id: setting_top_margins_is_hard
                width: parent.width
                height: 12
                // when top bar gets reduced, change this to 40
                // height: 40

                TextBody {
                    style: TextBody.Base
                    text: qsTr("SENSOR INFORMATION")
                    font.weight: Font.Bold
                    font.letterSpacing: 4
                    horizontalAlignment: Text.AlignHCenter
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            AdvancedInfoToolheadsItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoChamberItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoMiscItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoDragonItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
                visible: !bot.hasFilamentBay
            }

            AdvancedInfoFilamentBaysItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
                visible: bot.hasFilamentBay
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoMotionStatusItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoCalibrationItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
            }
        }
    }
}
