import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

Item {
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

    width: 800
    height: 440
    smooth: false
    antialiasing: false

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
            signInSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(itemToDisplayDefaultIndex == 0) {
                setCurrentItem(settingsSwipeView.itemAt(7))
            } else {
                setCurrentItem(signInSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
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
                source: "qrc:/img/add_account_image.png"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 50
            }

            Item {
                id: text
                width: 400
                height: 250
                visible: true
                anchors.left: addAccountImage.right
                anchors.leftMargin: 100
                anchors.top: addAccountImage.top

                TitleText {
                    id: title
                    width: 252
                    text: "AUTHORIZE MAKERBOT ACCOUNT"
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }

                BodyText {
                    id: body
                    width: 350
                    anchors.top: title.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    text: "Sign in with your MakerBot Account to add this printer to your printer list. If you do not have a MakerBot Account, please visit MakerBot.com to create an account."
                }

                RoundedButton {
                    id: addAccountButton
                    label: "Add Account"
                    buttonWidth: 260
                    buttonHeight: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.top: body.bottom
                    anchors.topMargin: 20
                    visible: true
                }
            }
        }

        // settingsSwipeView.index = 1
        Item {
            id: enterUsernameView
            property var backSwiper: signInSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

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
                    font.family: "Antennae"
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
                    font.family: "Antennae"
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
                }

                Button {
                    id: noAccountButton
                    anchors.left: usernameTextField.left
                    anchors.top: usernameTextField.bottom
                    anchors.topMargin: 15
                    padding: 0

                    contentItem: Text {
                        text: "Don't have a MakerBot account?"
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: "Antennae"
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
                    font.family: "Antennae"
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
                    font.family: "Antennae"
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
                    }

                    Text {
                        id: showPasswordText
                        text: " Show Password"
                        font.wordSpacing: 1
                        font.pointSize: 12
                        color: "#ffffff"
                        font.family: "Antennae"
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
                            font.family: "Antennae"
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
    }

    Item {
        id: inputPanelContainer
        smooth: false
        antialiasing: false
        visible: Qt.inputMethod.visible
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
        }
    }

    Component {
        id: noAccountContents
        Item {
            anchors.fill: parent

            TitleText {
                id: noAccountText
                text: "PLEASE VISIT MAKERBOT.COM TO CREATE AN ACCOUNT"
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
            }
        }
    }

    Component {
        id: resetPasswordContents

        Item {
            anchors.fill: parent

            TitleText {
                id: resetPasswordText
                text: "VISIT MAKERBOT.COM TO RESET YOUR PASSWORD"
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
            }
        }
    }

    Component {
        id: authorizingContents

        // nested items; sorta dumb looking, but necessary (probably)...
        Item {
            anchors.fill: parent

            Item {
                anchors.centerIn: parent
                height: authorizingText.height + authorizingImage.height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: authorizingImage
                    anchors.centerIn: parent
                    source: "qrc:/img/loading.png"
                }

                TitleText {
                    id: authorizingText
                    text: "AUTHORIZING ACCOUNT"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.bottom: authorizingImage.top
                    anchors.bottomMargin: 25
                    anchors.horizontalCenter: authorizingImage.horizontalCenter
                }
            }
        }
    }

    Component {
        id: signInFailedContents

        Item {
            anchors.fill: parent

            Item {
                anchors.centerIn: parent
                height: signInFailedTitle.height + signInFailedBody.height
                width: parent.width

                TitleText {
                    id: signInFailedTitle
                    text: "THERE WAS A PROBLEM AUTHENTICATING YOUR ACCOUNT"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }

                BodyText {
                    id: signInFailedBody
                    text: "The username or password you provided was invalid. Please try again."
                    anchors.top: signInFailedTitle.bottom
                    anchors.horizontalCenter: signInFailedTitle.horizontalCenter
                }
            }
        }
    }

    Component {
        id: signInSucceededContents

        Item {
            anchors.fill: parent

            Component.onDestruction: {
                backToSettings();
            }

            Image {
                id: authCompleteImage
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/account_auth_complete.png"
                anchors.left: parent.left
                anchors.leftMargin: 50
            }

            TitleText {
                id: signInSucceededTitle
                text: "AUTHENTICATION\nCOMPLETE"
                anchors.left: authCompleteImage.right
                anchors.leftMargin: 80
                anchors.top: authCompleteImage.top
            }

            BodyText {
                id: signInSucceededBody
                text: "<b>" + username + "</b><br>is now authenticated to this printer."
                anchors.left: authCompleteImage.right
                anchors.leftMargin: 80
                anchors.bottom: authCompleteImage.bottom
            }
        }
    }
}
