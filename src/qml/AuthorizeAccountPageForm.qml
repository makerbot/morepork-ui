import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: authorizeAccountPage
    property alias authorizeAccountSwipeView: authorizeAccountSwipeView
    property alias defaultItem: itemSelectAuthorizeMethod

    property alias buttonAuthorizeWithCode: buttonAuthorizeWithCode
    property alias buttonLoginToMakerbotAccount: buttonLoginToMakerbotAccount

    property alias authorizeAccountWithCodePage: authorizeAccountWithCodePage

    property alias signInPage: signInPage
    property alias authorizeAccountPopup: authorizeAccountPopup

    property string username: ""

    smooth: false
    anchors.fill: parent

    enum PageIndex {
        ChooseAuthMethod,
        AuthorizeWithCode,
        AuthorizeWithCredentials
    }

    SwipeView {
        id: authorizeAccountSwipeView
        currentIndex: AuthorizeAccountPage.ChooseAuthMethod
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = authorizeAccountSwipeView.currentIndex
            if (prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            authorizeAccountSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(itemToDisplayDefaultIndex == AuthorizeAccountPage.ChooseAuthMethod) {
                // When we swipe to the 0th index of this page set
                // the current item as the settings page item that
                // holds this page since we want the back button to
                // use the settings items altBack()
                setCurrentItem(settingsSwipeView.itemAt(SettingsPage.AuthorizeAccountsPage))
            } else {
                setCurrentItem(authorizeAccountSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
            authorizeAccountSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            authorizeAccountSwipeView.itemAt(prevIndex).visible = false
        }

        // AuthorizeAccountPage.ChooseAuthMethod
        Item {
            id: itemSelectAuthorizeMethod
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: true

            Flickable {
                id: flickableAuthorizeMethod
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: false
                anchors.fill: parent
                contentHeight: columnAuthorizeMethod.height

                Column {
                    id: columnAuthorizeMethod
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonAuthorizeWithCode
                        buttonImage.source: "qrc:/img/icon_authorize_account.png"
                        buttonText.text: qsTr("AUTHORIZE WITH CODE")
                    }

                    MenuButton {
                        id: buttonLoginToMakerbotAccount
                        buttonImage.source: "qrc:/img/icon_authorize_account.png"
                        buttonText.text: qsTr("LOG IN TO MAKERBOT ACCOUNT")
                    }
                }
            }
        }

        // AuthorizeAccountPage.AuthorizeWithCode
        Item {
            id: authorizeWithCodeItem
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: authorizeAccountSwipeView
            property int backSwipeIndex: AuthorizeAccountPage.ChooseAuthMethod
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                authorizeAccountWithCodePage.disconnectHandlers()
                authorizeAccountWithCodePage.checkAuthTimer.stop()
                authorizeAccountWithCodePage.expireOTPTimer.stop()
                authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
            }

            AuthorizeAccountWithCode {
                id: authorizeAccountWithCodePage
            }
        }

        // AuthorizeAccountPage.AuthorizeWithCredentials
        Item {
            id: loginToAccountItem
            property var backSwiper: authorizeAccountSwipeView
            property int backSwipeIndex: AuthorizeAccountPage.ChooseAuthMethod
            smooth: false
            visible: false

            SignInPage {
                id: signInPage
            }
        }
    }

    // This popup is common for both methods of signing into
    // the printer.
    CustomPopup {
        id: authorizeAccountPopup
        popupWidth: 720
        popupHeight: 305

        // popups dont have native states support yet
        property var state

        showOneButton: state == "no_account" ||
                       state == "reset_password" ||
                       state == "authorization_failed" ||
                       state == "failed_to_get_otp"
        full_button_text: {
            if(state == "no_account") {
                qsTr("DONE")
            } else if(state == "reset_password") {
                qsTr("DONE")
            } else if(state == "authorization_failed") {
                qsTr("TRY AGAIN")
            } else if(state == "failed_to_get_otp") {
                qsTr("DONE")
            }
        }

        full_button.onClicked: {
            if(state == "no_account") {
                authorizeAccountPopup.close()
            } else if(state == "reset_password") {
                authorizeAccountPopup.close()
            } else if(state == "authorization_failed") {
                authorizeAccountPopup.close()
            } else if(state == "failed_to_get_otp") {
                backToSelectAuthMethod()
            }
        }

        RowLayout {
            id: contents
            width: 600
            height: 300
            anchors.verticalCenter: authorizeAccountPopup.popupContainer.verticalCenter
            anchors.verticalCenterOffset: -30
            anchors.horizontalCenter: authorizeAccountPopup.popupContainer.horizontalCenter
            state: authorizeAccountPopup.state
            spacing: 20

            Image {
                id: authCompleteImage
                Layout.alignment: Qt.AlignVCenter
                width: sourceSize.width
                height: sourceSize.height
                source: "qrc:/img/account_auth_complete.png"
            }

            ColumnLayout {
                id: textContainer
                height: children.height
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 15
                Text {
                    id: titleText
                    color: "#cbcbcb"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.letterSpacing: 3
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 22
                    lineHeight: 1.3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                BusySpinner {
                    id: waitingSpinner
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    spinnerSize: 64
                }

                Text {
                    id: subtitleText
                    color: "#cbcbcb"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    font.letterSpacing: 1
                    lineHeight: 1.3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }

            states: [
                State {
                    name: "no_account"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("PLEASE VISIT MAKERBOT.COM TO<br>CREATE AN ACCOUNT")
                    }

                    PropertyChanges {
                        target: subtitleText
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }
                },
                State {
                    name: "reset_password"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("PLEASE VISIT MAKERBOT.COM TO<br>RESET YOUR PASSWORD")
                    }

                    PropertyChanges {
                        target: subtitleText
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }
                },
                State {
                    name: "authorizing"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHORIZING ACCOUNT")
                    }

                    PropertyChanges {
                        target: subtitleText
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: true
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }

                    PropertyChanges {
                        target: contents
                        anchors.verticalCenterOffset: 0
                    }
                },
                State {
                    name: "authorization_failed"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHENTICATION ERROR")
                    }

                    PropertyChanges {
                        target: subtitleText
                        text: qsTr("The username or password did not match. Please try again.")
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }
                },
                State {
                    name: "authorization_successful"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHENTICATION\nCOMPLETE")
                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft
                    }

                    PropertyChanges {
                        target: subtitleText
                        text: qsTr("<b>%1</b><br>is now authenticated to this printer.").arg(username)
                        visible: true
                        horizontalAlignment: Text.AlignLeft
                        Layout.alignment: Qt.AlignLeft
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: true
                    }

                    PropertyChanges {
                        target: contents
                        anchors.verticalCenterOffset: 0
                    }
                },
                State {
                    name: "connecting_to_get_otp"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("CONNECTING")
                    }

                    PropertyChanges {
                        target: subtitleText
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: true
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }

                    PropertyChanges {
                        target: contents
                        anchors.verticalCenterOffset: 0
                    }
                },
                State {
                    name: "failed_to_get_otp"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("FAILED TO GET CODE")
                    }

                    PropertyChanges {
                        target: subtitleText
                        text: qsTr("Please check your network connection or try again later.")
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: authCompleteImage
                        visible: false
                    }
                }
            ]
        }
    }
}
