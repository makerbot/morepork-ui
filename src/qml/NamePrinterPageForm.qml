import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3
import FreStepEnum 1.0

Item {
    width: 800
    height: 420
    smooth: false
    antialiasing: false
    property alias defaultItem: itemNamePrinter
    property alias namePrinterSwipeView: namePrinterSwipeView
    property alias nameField: nameField

    enum SwipeIndex {
        EnterName,
        ConfirmName
    }

    SwipeView {
        id: namePrinterSwipeView
        smooth: false
        currentIndex: NamePrinterPage.EnterName
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = namePrinterSwipeView.currentIndex
            namePrinterSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(itemToDisplayDefaultIndex == NamePrinterPage.EnterName) {
                // When we swipe to the 0th index of this page set
                // the current item as the settings page item that
                // holds this page since we want the back button to
                // use the settings items altBack()
                setCurrentItem(settingsSwipeView.itemAt(SettingsPage.ChangePrinterNamePage))
            } else {
                setCurrentItem(namePrinterSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
            namePrinterSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            namePrinterSwipeView.itemAt(prevIndex).visible = false
        }

        // NamePrinterPage.EnterName
        Item {
            id: itemNamePrinter
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: true

            Item {
                id: appContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: inputPanelContainer.top
                smooth: false
                antialiasing: false

                Text {
                    text: qsTr("ENTER A NAME FOR YOUR PRINTER")
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: nameField.left
                    anchors.bottom: nameField.top
                    anchors.bottomMargin: 10
                    font.family: defaultFont.name
                    font.weight: Font.Light
                }

                TextField {
                    id: nameField
                    width: 440
                    height: 44
                    smooth: false
                    antialiasing: false
                    anchors.top: parent.top
                    anchors.topMargin: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 50
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

                RoundedButton {
                    id: connectButton
                    anchors.left: nameField.right
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    label_width: 150
                    label: qsTr("ENTER")
                    buttonWidth: 160
                    buttonHeight: 50
                    button_mouseArea.onClicked: {
                        namePrinterSwipeView.swipeToItem(NamePrinterPage.ConfirmName)
                    }
                }
            }

            Item {
                id: inputPanelContainer
                smooth: false
                antialiasing: false
                visible: settingsSwipeView.currentIndex == SettingsPage.ChangePrinterNamePage &&
                         namePrinterSwipeView.currentIndex == NamePrinterPage.EnterName
                x: -30
                y: parent.height - inputPanel.height + 22
                width: 860
                height: inputPanel.height
                InputPanel {
                    id: inputPanel
                    //y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                    antialiasing: false
                    smooth: false
                    anchors.fill: parent
                    active: true
                }
            }
        }

        // NamePrinterPage.ConfirmName
        Item {
            id: itemConfirmName
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: namePrinterSwipeView
            property int backSwipeIndex: NamePrinterPage.EnterName
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                namePrinterSwipeView.swipeToItem(NamePrinterPage.EnterName)
                namePrinter.nameField.forceActiveFocus()
            }

            Image {
                id: name_printer_image
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -15
                source: "qrc:/img/name_printer.png"
            }

            Item {
                id: confirm_name_item
                width: 400
                height: 300
                anchors.left: name_printer_image.right
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: printer_name_label
                    color: "#ffffff"
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    text: qsTr("PRINTER NAME")
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    font.pixelSize: 20
                    font.letterSpacing: 3
                }

                Text {
                    id: printer_name_text
                    color: "#ffffff"
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    text: {
                        if(nameField.text == "") {
                            nameField.placeholderText
                        }
                        else {
                            nameField.text
                        }
                    }
                    anchors.top: printer_name_label.bottom
                    anchors.topMargin: 25
                    font.pixelSize: 18
                    font.letterSpacing: 2
                }

                RoundedButton {
                    id: continueWithNameButton
                    anchors.top: printer_name_text.bottom
                    anchors.topMargin: 55
                    label: qsTr("CONTINUE")
                    buttonWidth: 200
                    buttonHeight: 50
                    label_width: 200
                    button_mouseArea.onClicked: {
                        if(nameField.text == "") {
                            bot.changeMachineName(nameField.placeholderText)
                        }
                        else {
                            bot.changeMachineName(nameField.text)
                        }
                        namePrinterSwipeView.swipeToItem(NamePrinterPage.EnterName)
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        if(inFreStep) {
                            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                            fre.gotoNextStep(currentFreStep)
                        }
                    }
                }
            }
        }
    }
}
