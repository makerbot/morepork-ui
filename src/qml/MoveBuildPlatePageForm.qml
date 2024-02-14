import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: moveBuildPlatePage
    smooth: false
    anchors.fill: parent

    property alias moveBuildPlatePageSwipeView: moveBuildPlatePageSwipeView

    property alias buttonRaiseToTop: buttonRaiseToTop
    property alias buttonLowerToBottom: buttonLowerToBottom

    property alias customMoveBuildPlate: customMoveBuildPlate
    property alias buttonCustomMoveBuildPlate: buttonCustomMoveBuildPlate
    property alias doorOpenMoveBuildPlatePopup: doorOpenMoveBuildPlatePopup

    enum SwipeIndex {
        BasePage,                   //0
        CustomMoveBuildPlatePage    //1
    }

    LoggingStackLayout {
        id: moveBuildPlatePageSwipeView
        logName: "moveBuildPlatePageSwipeView"
        currentIndex: MoveBuildPlatePage.BasePage

        // MoveBuildPlatePage.BasePage
        Item {
            id: itemMoveBuildPlatePage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: buildPlateSettingsPage.buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            property string topBarTitle: qsTr("Raise/Lower Build Plate")
            smooth: false

            FlickableMenu {
                id: flickableMoveBuildPlate
                contentHeight: columnMoveBuildPlate.height

                Column {
                    id: columnMoveBuildPlate
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonRaiseToTop
                        buttonImage.source: "qrc:/img/icon_raise.png"
                        buttonText.text: qsTr("RAISE TO TOP")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonLowerToBottom
                        buttonImage.source: "qrc:/img/icon_lower.png"
                        buttonText.text: qsTr("LOWER TO BOTTOM")
                        visible: bot.machineType == MachineType.Magma
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCustomMoveBuildPlate
                        buttonImage.source: "qrc:/img/icon_raise_lower_bp.png"
                        buttonText.text: qsTr("MOVE TO CUSTOM HEIGHT")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // MoveBuildPlatePage.CustomMoveBuildPlatePage
        Item {
            id: customMoveBuildPlateItem
            property var backSwiper: moveBuildPlatePageSwipeView
            property int backSwipeIndex: MoveBuildPlatePage.BasePage
            property string topBarTitle: qsTr("Move To Custom Height")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                customMoveBuildPlate.disableArrows()
                moveBuildPlatePageSwipeView.swipeToItem(MoveBuildPlatePage.BasePage)
            }

            CustomMoveBuildPlate {
                id: customMoveBuildPlate
            }
        }
    }

    CustomPopup {
        popupName: "DoorOpenMoveBuildPlatePopup"
        id: doorOpenMoveBuildPlatePopup
        showOneButton: true
        full_button.onClicked: doorOpenMoveBuildPlatePopup.close()
        full_button_text: qsTr("CONFIRM")

        ColumnLayout {
            spacing: 10
            anchors.top: parent.top
            anchors.topMargin: 125
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                source: "qrc:/img/process_error_small.png"
                Layout.alignment: Qt.AlignHCenter
            }
            TextHeadline {
                text: qsTr("FRONT DOOR OPEN")
                Layout.alignment: Qt.AlignHCenter
            }
            TextBody {
                text: qsTr("Close the front door to proceed.")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}

