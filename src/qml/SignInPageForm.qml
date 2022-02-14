import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

Item {
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias signInSwipeView: signInSwipeView

    property alias addAccountButton: addAccountButton

    property alias noAccountButton: noAccountButton
    property alias enteredUsernameButton: enteredUsernameButton
    property alias usernameTextField: usernameTextField

    property alias authorizeButton: authorizeButton
    property alias showPassword: showPassword
    property alias passwordField: passwordField
    property alias forgotPasswordButton: forgotPasswordButton

    enum SwipeIndex {
        BasePage,
        UsernamePage,
        PasswordPage
    }

    LoggingSwipeView {
        id: signInSwipeView
        logName: "signInSwipeView"
        currentIndex: SignInPage.BasePage

        function customEntryCheck(swipeToIndex) {
            // Skip showing the base page when we swipe through directly to
            // the username page while in the FRE.
            if(swipeToIndex == SignInPage.UsernamePage && inFreStep) {
                authorizeAccountView.visible = false
            }
        }

        // SignInPage.BasePage
        Item {
            id: authorizeAccountView
            property var backSwiper: authorizeAccountSwipeView
            property int backSwipeIndex: AuthorizeAccountPage.ChooseAuthMethod
            smooth: false
            visible: true

            Image {
                id: addAccountImage
                anchors.verticalCenterOffset: -24
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/add_account_image.png"
                anchors.left: parent.left
                anchors.leftMargin: 50

                Item {
                    id: mainItem
                    width: 400
                    height: 300
                    anchors.verticalCenterOffset: 15
                    anchors.verticalCenter: parent.verticalCenter
                    visible: true
                    anchors.left: addAccountImage.right
                    anchors.leftMargin: 100

                    Text {
                        id: title
                        width: 375
                        text: qsTr("AUTHORIZE MAKERBOT ACCOUNT")
                        antialiasing: false
                        smooth: false
                        font.letterSpacing: 3
                        wrapMode: Text.WordWrap
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        color: "#e6e6e6"
                        font.family: defaultFont.name
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        lineHeight: 1.2
                        visible: true
                    }

                    Text {
                        id: subtitle
                        width: 350
                        wrapMode: Text.WordWrap
                        anchors.top: title.bottom
                        anchors.topMargin: 20
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        color: "#e6e6e6"
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        font.weight: Font.Light
                        text: qsTr("Sign in with your MakerBot Account to add this printer to your printer list. If you do not have a MakerBot Account, please visit MakerBot.com to create an account.")
                        lineHeight: 1.2
                        visible: true
                    }

                    RoundedButton {
                        id: addAccountButton
                        label: qsTr("ADD ACCOUNT")
                        buttonWidth: 260
                        buttonHeight: 50
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.top: subtitle.bottom
                        anchors.topMargin: 25
                        visible: true
                    }
                }
            }
        }

        // SignInPage.UsernamePage
        Item {
            id: enterUsernameView
            property var backSwiper: signInSwipeView
            property int backSwipeIndex: SignInPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                usernameTextField.clear()
                if(!inFreStep) {
                    signInSwipeView.swipeToItem(SignInPage.BasePage)
                } else {
                    authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
                }
            }

            Item {
                id: enterUsernameContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                smooth: false
                antialiasing: false

                Text {
                    text: qsTr("ENTER USERNAME OR EMAIL")
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: usernameTextField.left
                    anchors.bottom: usernameTextField.top
                    anchors.bottomMargin: 12
                    font.family: defaultFont.name
                    font.weight: Font.Light
                }

                TextField {
                    id: usernameTextField
                    width: 440
                    height: 44
                    smooth: false
                    antialiasing: false
                    anchors.top: parent.top
                    anchors.topMargin: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pointSize: 14
                    background: Rectangle {
                        radius: 2
                        anchors.fill: parent
                        color: "#f7f7f7"
                    }
                }

                RoundedButton {
                    id: enteredUsernameButton
                    anchors.left: usernameTextField.right
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    label_width: 150
                    label: qsTr("NEXT")
                    buttonWidth: 160
                    buttonHeight: 50
                    disable_button: usernameTextField.text == ""
                }

                Button {
                    id: noAccountButton
                    anchors.left: usernameTextField.left
                    anchors.top: usernameTextField.bottom
                    anchors.topMargin: 20
                    padding: 0

                    contentItem: Text {
                        text: qsTr("Don't have a MakerBot account?")
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        //anchors.left: usernameTextField.left
                    }

                    background: Rectangle {
                        opacity: 0.0
                    }
                }
            }
        }

        // SignInPage.PasswordPage
        Item {
            id: enterPasswordView
            property var backSwiper: signInSwipeView
            property int backSwipeIndex: SignInPage.UsernamePage
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                passwordField.clear()
                showPassword.checked = false
                signInSwipeView.swipeToItem(SignInPage.UsernamePage)
                usernameTextField.forceActiveFocus()
            }

            Item {
                id: enterPasswordContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                smooth: false
                antialiasing: false

                Text {
                    text: qsTr("ENTER ACCOUNT PASSWORD")
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
                    background: Rectangle {
                        radius: 2
                        anchors.fill: parent
                        color: "#f7f7f7"
                    }
                    color: "#000000"
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pointSize: (showPassword.checked ||
                                    text == "") ? 14 : 24
                    passwordCharacter: "•"
                    echoMode: {
                        showPassword.checked ?
                                    TextField.Normal:
                                    TextField.Password
                    }
                }

                RoundedButton {
                    id: authorizeButton
                    anchors.left: passwordField.right
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    label_width: 150
                    label: qsTr("AUTHORIZE")
                    buttonHeight: 50
                }

                RowLayout {
                    id: rowLayout
                    anchors.leftMargin: -3
                    anchors.top: passwordField.bottom
                    anchors.topMargin: 10
                    anchors.left: passwordField.left
                    anchors.right: passwordField.right
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    CheckBox {
                        id: showPassword
                        checked: false
                        onPressed: passwordField.forceActiveFocus()
                        Layout.alignment: Qt.AlignLeft
                    }

                    Text {
                        id: showPasswordText
                        text: qsTr("Show Password")
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        Layout.alignment: Qt.AlignLeft
                    }

                    Button {
                        id: forgotPasswordButton
                        padding: 0
                        Layout.alignment: Qt.AlignRight

                        contentItem: Text {
                            text: qsTr("Forgot Password?")
                            font.wordSpacing: 1
                            font.pointSize: 12
                            color: "#ffffff"
                            font.family: defaultFont.name
                            font.weight: Font.Light
                        }

                        background: Rectangle {
                            opacity: 0.0
                        }
                    }
                }
            }
        }
    }

    Item {
        id: inputPanelContainer
        smooth: false
        antialiasing: false
        visible: settingsSwipeView.currentIndex == SettingsPage.AuthorizeAccountsPage &&
                 (signInSwipeView.currentIndex == SignInPage.UsernamePage ||
                  signInSwipeView.currentIndex == SignInPage.PasswordPage)
        x: -30
        y: inputPanel && parent ? parent.height - inputPanel.height : 0
        z: 1
        width: 860
        height: inputPanel.height
        InputPanel {
            id: inputPanel
            antialiasing: false
            smooth: false
            anchors.fill: parent
            active: true
        }
    }
}
