import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import DFSEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias wifiSwipeView: koreaDFScreenSwipeView
    property alias passwordField: passwordField

    enum SwipeIndex {
        BasePage,
        ChangeDFSSettingPage
    }

    LoggingSwipeView {
        id: koreaDFScreenSwipeView
        logName: "koreaDFScreenSwipeView"
        currentIndex: 0 // Should never be non zero

        // advancedSettingsSwipeView.index = 0
        Item {
            id: itemEnterPassword
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: true

            function altBack() {
                passwordField.clear()
                showPassword.checked = false
                advancedSettingsSwipeView.swipeToItem(SettingsPage.BasePage)
            }

            Item {
                id: appContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: inputPanelContainer.top
                smooth: false
                antialiasing: false

                Text {
                    text: qsTr("CHANGE DFS SETTINGS")
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: passwordField.left
                    anchors.bottom: passwordField.top
                    anchors.bottomMargin: 10
                    font.family: defaultFont.name
                    font.weight: Font.Light
                }

                TextField {
                    id: passwordField
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
                    font.pointSize: (showPassword.checked ||
                                    text == "") ? 14 : 24
                    placeholderText: "Enter password"
                    passwordCharacter: "•"
                    echoMode: {
                        showPassword.checked ?
                                    TextField.Normal:
                                    TextField.Password
                    }
                }

                RoundedButton {
                    id: enterButton
                    anchors.left: passwordField.right
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    label_width: 150
                    label: qsTr("ENTER")
                    buttonWidth: 160
                    buttonHeight: 50
                    button_mouseArea.onClicked: {
                        if(passwordField.text === "methodkorea") {
                            koreaDFScreenSwipeView.swipeToItem(KoreaDFSScreen.ChangeDFSSettingPage)
                        }
                    }
                }

                RowLayout {
                    id: rowLayout
                    anchors.leftMargin: -3
                    anchors.top: passwordField.bottom
                    anchors.topMargin: 10
                    anchors.left: passwordField.left
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    CheckBox {
                        id: showPassword
                        checked: false
                        onPressed: passwordField.forceActiveFocus()
                        indicator: Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                x: showPassword.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: showPassword.down ? lightBlue : otherBlue

                                Rectangle {
                                    width: 14
                                    height: 14
                                    x: 6
                                    y: 6
                                    radius: 2
                                    color: showPassword.down ? lightBlue : otherBlue
                                    visible: showPassword.checked
                                }
                            }
                    }

                    Text {
                        id: show_password_text
                        color: "#ffffff"
                        text: qsTr("Show Password")
                        font.letterSpacing: 2
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pixelSize: 18
                    }
                }
            }
        }

        // advancedSettingsSwipeView.index = 1
        Item {
            id: itemKoreaDFSSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: koreaDFScreenSwipeView
            property int backSwipeIndex: KoreaDFSScreen.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: true

            function altBack() {
            }

            Text {
                id: koreaDFSModeLabel
                text: qsTr("KOREA DFS MODE")
                anchors.topMargin: 100
                anchors.leftMargin: 50
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1.5
                font.wordSpacing: 1
                font.pointSize: 12
                color: "#ffffff"
                anchors.left: parent.left
                anchors.top: parent.top
                font.family: defaultFont.name
                font.weight: Font.Light
            }

            SlidingSwitch {
                id: switchkoreasDFSMode
                anchors.verticalCenter: koreaDFSModeLabel.verticalCenter
                checked: dfs.DFSRegion == DFS.Korea
                anchors.left: koreaDFSModeLabel.right
                anchors.leftMargin: 50
                onClicked: {
                    // The UI just sets a persistent flag that kaiten
                    // checks while initializing network stuff to
                    // set the DFS region.
                    if(switchkoreasDFSMode.checked) {
                        dfs.updateDFSSetting(DFS.Korea)
                    }
                    else if(!switchkoreasDFSMode.checked) {
                        dfs.updateDFSSetting(DFS.Global)
                    }
                }
            }

            RoundedButton {
                id: okButton
                buttonHeight: 50
                buttonWidth: 120
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("DONE")

                button_mouseArea {
                    onClicked: {
                        passwordField.clear()
                        showPassword.checked = false
                        koreaDFScreenSwipeView.swipeToItem(KoreaDFSScreen.BasePage)
                        advancedSettingsSwipeView.swipeToItem(SettingsPage.BasePage)
                    }
                }
            }
        }
    }
}
