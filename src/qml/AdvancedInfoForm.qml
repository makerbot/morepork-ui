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
            spacing: 0

            AdvancedInfoToolheadsItem {
                anchors.left: parent.left
                anchors.leftMargin: 40

            }

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 40
                spacing: 0
                AdvancedInfoChamberItem {

                }

                AdvancedInfoMiscItem {

                }
            }

            AdvancedInfoFilamentBaysItem {
                anchors.left: parent.left
                anchors.leftMargin: 40
                visible: bot.hasFilamentBay
            }

            AdvancedInfoMotionStatusItem {
                anchors.left: parent.left
                anchors.leftMargin: 40
            }

            AdvancedInfoCalibrationItem {
                anchors.left: parent.left
                anchors.leftMargin: 40
            }
        }
    }
}
