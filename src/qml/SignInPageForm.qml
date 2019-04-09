import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

Item {
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias defaultItem: authorizeAccountView
    property alias signInSwipeView: signInSwipeView

    property alias addAccountButton: addAccountButton

    property alias noAccountButton: noAccountButton
    property alias enteredUsernameButton: enteredUsernameButton
    property alias usernameTextField: usernameTextField

    property alias authorizeButton: authorizeButton
    property alias showPassword: showPassword
    property alias passwordField: passwordField
    property alias forgotPasswordButton: forgotPasswordButton

    property alias signInPagePopup: signInPagePopup
    property alias authorizingContents: authorizingContents
    property alias noAccountContents: noAccountContents
    property alias resetPasswordContents: resetPasswordContents
    property alias signInFailedContents: signInFailedContents
    property alias signInSucceededContents: signInSucceededContents

    property string username: ""

    SwipeView {
        id: signInSwipeView
        smooth: false
        currentIndex: 0
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = signInSwipeView.currentIndex
            if (prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            // Skip showing the first page when we swipe through to
            // the second page while in the fre.
            if(itemToDisplayDefaultIndex == 1 && inFreStep) {
                authorizeAccountView.visible = false
            }
            signInSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(signInSwipeView.itemAt(itemToDisplayDefaultIndex))
            signInSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
        }

        // settingsSwipeView.index = 0
        Item {
            id: authorizeAccountView
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
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
                        text: "AUTHORIZE MAKERBOT ACCOUNT"
                        antialiasing: false
                        smooth: false
                        font.letterSpacing: 3
                        wrapMode: Text.WordWrap
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        color: "#e6e6e6"
                        font.family: "Antenna"
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
                        font.family: "Antenna"
                        font.pixelSize: 18
                        font.weight: Font.Light
                        text: "Sign in with your MakerBot Account to add this printer to your printer list. If you do not have a MakerBot Account, please visit MakerBot.com to create an account."
                        lineHeight: 1.2
                        visible: true
                    }

                    RoundedButton {
                        id: addAccountButton
                        label: "ADD ACCOUNT"
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

        // settingsSwipeView.index = 1
        Item {
            id: enterUsernameView
            property var backSwiper: signInSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    signInSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                signInPage.backToSettings()
                mainSwipeView.swipeToItem(0)
            }

            Item {
                id: enterUsernameContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                smooth: false
                antialiasing: false

                Text {
                    text: "ENTER USERNAME OR EMAIL"
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: usernameTextField.left
                    anchors.bottom: usernameTextField.top
                    anchors.bottomMargin: 12
                    font.family: "Antenna"
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
                    font.family: "Antenna"
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
                    label: "NEXT"
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
                        text: "Don't have a MakerBot account?"
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: "Antenna"
                        font.weight: Font.Light
                        //anchors.left: usernameTextField.left
                    }

                    background: Rectangle {
                        opacity: 0.0
                    }
                }
            }
        }

        // idx = 2
        Item {
            id: enterPasswordView
            property var backSwiper: signInSwipeView
            property int backSwipeIndex: 1
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                passwordField.clear()
                showPassword.checked = false
                signInSwipeView.swipeToItem(1)
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
                    text: "ENTER ACCOUNT PASSWORD"
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: passwordField.left
                    anchors.bottom: passwordField.top
                    anchors.bottomMargin: 10
                    font.family: "Antenna"
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
                    font.family: "Antenna"
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
                    label: "AUTHORIZE"
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
                    }

                    Text {
                        id: showPasswordText
                        text: " Show Password"
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: "Antenna"
                        font.weight: Font.Light
                        anchors.left: showPassword.right
                    }

                    Button {
                        id: forgotPasswordButton
                        anchors.right: rowLayout.right
                        padding: 0

                        contentItem: Text {
                            text: "Forgot Password?"
                            font.wordSpacing: 1
                            font.pointSize: 12
                            color: "#ffffff"
                            font.family: "Antenna"
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

    ModalPopup {
        id: signInPagePopup
        height: 275
        closePolicy: Popup.NoAutoClose
    }

    Item {
        id: inputPanelContainer
        smooth: false
        antialiasing: false
        visible: settingsSwipeView.currentIndex == 4 &&
                 (signInSwipeView.currentIndex == 1 ||
                  signInSwipeView.currentIndex == 2)
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

    Component {
        id: noAccountContents

        Item {
            anchors.fill: parent
            Text {
                id: noAccountText
                width: 600
                text: "PLEASE VISIT MAKERBOT.COM TO\nCREATE AN ACCOUNT."
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                color: "#e6e6e6"
                font.family: "Antenna"
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.4
                visible: true
            }
        }
    }

    Component {
        id: resetPasswordContents

        Item {
            anchors.fill: parent
            Text {
                id: resetPasswordText
                width: 600
                text: "VISIT MAKERBOT.COM TO RESET YOUR PASSWORD"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                color: "#e6e6e6"
                font.family: "Antenna"
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.4
                visible: true
            }
        }
    }

    Component {
        id: authorizingContents

        Item {
            anchors.fill: parent
            Text {
                id: authorizingText
                text: "AUTHORIZING ACCOUNT"
                anchors.top: parent.top
                anchors.topMargin: 60
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                color: "#e6e6e6"
                font.family: "Antenna"
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.2
                visible: true
            }

            BusySpinner {
                id: authorizingWaitingSpinner
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: authorizingText.bottom
                anchors.topMargin: 40
                spinnerActive: true
                spinnerSize: 64
            }
        }
    }

    Component {
        id: signInFailedContents

        Item {
            anchors.fill: parent
            Text {
                id: signInFailedText
                width: 600
                text: "AUTHENTICATION ERROR"
                anchors.top: parent.top
                anchors.topMargin: 60
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                color: "#e6e6e6"
                font.family: "Antenna"
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.2
                visible: true
            }

            Text {
                id: signInFailedBody
                color: "#cbcbcb"
                text: "The username or password did not match. Please try again."
                anchors.top: signInFailedText.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: "Antenna"
                font.pixelSize: 20
                lineHeight: 1.3
                visible: true
            }
        }
    }

    Component {
        id: signInSucceededContents

        Item {
            anchors.fill: parent
            Image {
                id: authCompleteImage
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/account_auth_complete.png"
                anchors.left: parent.left
                anchors.leftMargin: 50
            }
            Text {
                id: signInSucceededTitle
                text: "AUTHENTICATION\nCOMPLETE"
                anchors.left: authCompleteImage.right
                anchors.leftMargin: 70
                anchors.top: authCompleteImage.top
                anchors.topMargin: 15
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                color: "#e6e6e6"
                font.family: "Antenna"
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.4
                visible: true
            }

            Text {
                id: signInSucceededBody
                color: "#cbcbcb"
                text: "<b>" + username + "</b><br>is now authenticated to this printer."
                anchors.left: authCompleteImage.right
                anchors.leftMargin: 70
                anchors.bottom: authCompleteImage.bottom
                anchors.bottomMargin: 10
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: "Antenna"
                font.pixelSize: 20
                font.letterSpacing: 1
                lineHeight: 1.3
                visible: true
            }
        }
    }
}
