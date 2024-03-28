import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9
import FreStepEnum 1.0

Item {
    width: 800
    height: 420
    smooth: false
    antialiasing: false
    property alias nameField: nameField

    Item {
        id: itemNamePrinter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: inputPanelContainer.top
        smooth: false
        antialiasing: false

        ColumnLayout {
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter

            TextSubheader {
                text: qsTr("ENTER A NAME FOR YOUR PRINTER")
            }

            RowLayout {
                spacing: 20
                width: children.width
                TextField {
                    id: nameField
                    Layout.preferredWidth: 564
                    Layout.preferredHeight: 52
                    smooth: false
                    antialiasing: false
                    background:
                        Rectangle {
                            radius: 2
                            anchors.fill: parent
                            color: "#f7f7f7"
                        }
                    color: "#000000"
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pointSize: 14
                    placeholderText: "My Method Printer"
                    echoMode: TextField.Normal
                    focus: true
                }

                ButtonRectangleSecondary {
                    id: enterButton
                    Layout.preferredWidth: 120
                    text: qsTr("ENTER")
                    onClicked: {
                        confirmPrinterNamePopup.open()
                    }
                }
            }
        }
    }

    CustomPopup {
        popupName: "ConfirmPrinterName"
        id: confirmPrinterNamePopup
        popupHeight: 285
        showTwoButtons: true
        leftButtonText: qsTr("BACK")
        rightButtonText: qsTr("CONFIRM")
        leftButton.onClicked: {
            nameField.forceActiveFocus()
            confirmPrinterNamePopup.close()
        }
        rightButton.onClicked: {
            if(nameField.text == "") {
                bot.changeMachineName(nameField.placeholderText)
            } else {
                bot.changeMachineName(nameField.text)
            }
            systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
            if(inFreStep) {
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
            confirmPrinterNamePopup.close()
            nameField.clear()
        }

        ColumnLayout {
            spacing: 32
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -25

            Image {
                height: sourceSize.height
                width: sourceSize.width
                source: "qrc:/img/confirm_printer_name.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextHeadline {
                text: nameField.text ? nameField.text : nameField.placeholderText
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
