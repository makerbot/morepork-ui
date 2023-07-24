import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: moveBuildPlatePage

    enum SwipeIndex {
        BasePage,                   //0
        RaiseLowerBuildPlatePage    //1
    }

    LoggingSwipeView {
        id: moveBuildPlatePageSwipeView
        logName: "moveBuildPlatePageSwipeView"
        currentIndex: MoveBuildPlatePage.BasePage

        // BuildPlateSettingsPage.BasePage
        Item {
            id: itemMoveBuildPlatePage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Raise/Lower Build Plate")

            smooth: false

            Flickable {
                id: flickableCustomMoveBuildPlate
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnCustomMoveBuildPlate.height

                Column {
                    id: columnCustomMoveBuildPlate
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
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonRaiseLowerBuildPlate
                        buttonImage.source: "qrc:/img/icon_raise_lower_bp.png"
                        buttonText.text: qsTr("MOVE TO CUSTOM HEIGHT")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // BuildPlateSettingsPage.RaiseLowerBuildPlatePage
        Item {
            id: raiseLowerBuildPlateItem
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: CustomMoveBuildPlatePage.BasePage
            property string topBarTitle: qsTr("Raise/Lower Buildplate")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {

                raiseLowerBuildPlate.disableArrows()
                buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
            }

            RaiseLowerBuildPlate {
                id: raiseLowerBuildPlate
            }
        }
    }

    CustomPopup {
        popupName: "DoorOpenRaiseLowerBuildPlate"
        id: doorOpenRaiseLowerBuildPlatePopup
        showOneButton: true
        full_button.onClicked: doorOpenRaiseLowerBuildPlatePopup.close()
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

