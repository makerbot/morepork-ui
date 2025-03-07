import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: advancedInfo
    anchors.fill: parent
    smooth: false

    RefreshButton {
        anchors.bottomMargin: 10
        button_mouseArea.onClicked: {
            bot.query_status()
            bot.get_calibration_offsets()
        }
    }

    FlickableMenu {
        id: flickableAdvancedInfo
        contentHeight: columnContents.height
        anchors.topMargin: 35

        Column {
            id: columnContents
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            spacing: 50

            AdvancedInfoToolheadsItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 40
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
                anchors.right: parent.right
                anchors.rightMargin: 40
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
                anchors.right: parent.right
                anchors.rightMargin: 40
            }

            Rectangle {
                color: "#ffffff"
                height: 1
                width: parent.width
            }

            AdvancedInfoCalibrationItem {
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.right: parent.right
                anchors.rightMargin: 40
            }
            // Empty item to not make the refresh button cover the contents
            // of the page.
            Item {
                id: emptyItem
                width: parent.width
                height: 50
            }
        }
    }
}
