import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: authorizeAccountPage
    property alias authorizeAccountSwipeView: authorizeAccountSwipeView

    property alias buttonAuthorizeWithCode: buttonAuthorizeWithCode
    property alias buttonLoginToMakerbotAccount: buttonLoginToMakerbotAccount
    property alias buttonDeauthorizeAccounts: buttonDeauthorizeAccounts

    property alias authorizeAccountWithCodePage: authorizeAccountWithCodePage

    property alias signInPage: signInPage
    property alias authorizeAccountPopup: authorizeAccountPopup

    property string username: ""

    smooth: false
    anchors.fill: parent

    enum SwipeIndex {
        ChooseAuthMethod,
        AuthorizeWithCode,
        AuthorizeWithCredentials
    }

    LoggingStackLayout {
        id: authorizeAccountSwipeView
        logName: "authorizeAccountSwipeView"
        currentIndex: AuthorizeAccountPage.ChooseAuthMethod

        function customSetCurrentItem(swipeToIndex) {
            if(swipeToIndex == AuthorizeAccountPage.ChooseAuthMethod) {
                // When swiping to the 0th index of this swipeview set the
                // settings page item that holds this page as the current
                // item since we want the back button to use the settings
                // items' altBack()
                setCurrentItem(systemSettingsSwipeView.itemAt(SystemSettingsPage.AuthorizeAccountsPage))
                return true
            }
        }

        // AuthorizeAccountPage.ChooseAuthMethod
        Item {
            id: itemSelectAuthorizeMethod
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Choose Authorization Method")
            smooth: false
            visible: true

            FlickableMenu {
                id: flickableAuthorizeMethod
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

                    MenuButton {
                        id: buttonDeauthorizeAccounts
                        buttonImage.source: "qrc:/img/icon_deauthorize_accounts.png"
                        buttonText.text: qsTr("DEAUTHORIZE ALL ACCOUNTS")
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
            property string topBarTitle: qsTr("Authorize With Code")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    authorizeAccountWithCodePage.disconnectHandlers()
                    authorizeAccountWithCodePage.checkAuthTimer.stop()
                    authorizeAccountWithCodePage.expireOTPTimer.stop()
                    authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
                } else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                authorizeAccountWithCodePage.disconnectHandlers()
                authorizeAccountWithCodePage.checkAuthTimer.stop()
                authorizeAccountWithCodePage.expireOTPTimer.stop()
                authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
                backToSettings()
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
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
            property string topBarTitle: qsTr("Log In to Makerbot Account")
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
        popupName: "AccountsAuthorization"
        id: authorizeAccountPopup
        popupWidth: 720
        popupHeight: 305

        // popups dont have native states support yet
        property var state: emptyString

        showOneButton: state == "no_account" ||
                       state == "reset_password" ||
                       state == "authorization_failed" ||
                       state == "failed_to_get_otp"

        showTwoButtons: state == "deauthorize_accounts" ||
                        state == "no_network_connection"

        fullButtonText: {
            if(state == "no_account" ||
                    state == "reset_password" ||
                    state == "failed_to_get_otp") {
                qsTr("DONE")
            } else if(state == "authorization_failed") {
                qsTr("TRY AGAIN")
            } else {
                defaultString
            }
        }

        fullButton.onClicked: {
            if(state == "no_account" ||
                    state == "reset_password" ||
                    state == "authorization_failed") {
                authorizeAccountPopup.close()
            } else if(state == "failed_to_get_otp") {
                backToSelectAuthMethod()
            }
        }

        leftButtonText: {
            if(state == "deauthorize_accounts") {
                qsTr("BACK")
            } else if(state == "no_network_connection") {
                qsTr("CLOSE")
            } else {
                defaultString
            }
        }

        leftButton.onClicked: {
            if(state == "deauthorize_accounts") {
                authorizeAccountPopup.close()
            } else if(state == "no_network_connection") {
                authorizeAccountPopup.close()
            }
        }

        rightButtonText: {
            if(state == "deauthorize_accounts") {
                qsTr("CONFIRM")
            } else if(state == "no_network_connection") {
                qsTr("GO TO SETTINGS")
            } else {
                defaultString
            }
        }

        rightButton.onClicked: {
            if(state == "deauthorize_accounts") {
                bot.deauthorizeAllAccounts()
            } else if(state == "no_network_connection") {
                authorizeAccountPopup.close()
                backToSettings()
            }
        }

        ColumnLayout {
            height: children.height
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: 650
            anchors.verticalCenter: authorizeAccountPopup.popupContainer.verticalCenter
            anchors.verticalCenterOffset: -30
            anchors.horizontalCenter: authorizeAccountPopup.popupContainer.horizontalCenter
            state: authorizeAccountPopup.state
            spacing: 15

            Image {
                id: statusImage
                Layout.alignment: Qt.AlignHCenter
                width: sourceSize.width
                height: sourceSize.height
                source: "qrc:/img/process_complete_small.png"
            }

            BusySpinner {
                id: waitingSpinner
                Layout.alignment: Qt.AlignHCenter
                spinnerSize: 64
            }

            TextHeadline {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: parent.width
                wrapMode: Text.WordWrap
            }

            TextBody {
                id: subtitleText
                style: TextBody.Large
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: parent.width
                wrapMode: Text.WordWrap
            }

            states: [
                State {
                    name: "no_account"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("PLEASE VISIT MAKERBOT.COM TO CREATE AN ACCOUNT")
                        visible: true
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
                        target: statusImage
                        visible: false
                    }
                },
                State {
                    name: "reset_password"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("PLEASE VISIT MAKERBOT.COM TO RESET YOUR PASSWORD")
                        visible: true
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
                        target: statusImage
                        visible: false
                    }
                },
                State {
                    name: "authorizing"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHORIZING ACCOUNT")
                        visible: true
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
                        target: statusImage
                        visible: false
                    }
                },
                State {
                    name: "authorization_failed"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHENTICATION ERROR")
                        visible: true
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
                        target: statusImage
                        visible: true
                        source: "qrc:/img/process_error_small.png"
                    }
                },
                State {
                    name: "authorization_successful"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("AUTHORIZATION COMPLETE")
                        visible: true
                    }

                    PropertyChanges {
                        target: subtitleText
                        text: qsTr("%1 is now authorized to this printer.").arg("<b>"+username+"</b>")
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: statusImage
                        visible: true
                        source: "qrc:/img/process_complete_small.png"
                    }
                },
                State {
                    name: "connecting_to_get_otp"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("CONNECTING")
                        visible: true
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
                        target: statusImage
                        visible: false
                    }
                },
                State {
                    name: "failed_to_get_otp"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("FAILED TO GET CODE")
                        visible: true
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
                        target: statusImage
                        visible: true
                        source: "qrc:/img/process_error_small.png"
                    }
                },
                State {
                    name: "deauthorize_accounts"
                    PropertyChanges {
                        target: titleText
                        text: qsTr("DEAUTHORIZE ALL ACCOUNTS?")
                        visible: true
                    }

                    PropertyChanges {
                        target: subtitleText
                        text: qsTr("You will have to reauthorize any account you wish to connect to " +
                                   "this printer in the future.")
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: statusImage
                        visible: true
                        source: "qrc:/img/process_error_small.png"
                    }
                },
                State {
                    name: "no_network_connection"
                    PropertyChanges {
                        target: titleText
                        visible: true
                        text: qsTr("CONNECT TO NETWORK")
                    }

                    PropertyChanges {
                        target: subtitleText
                        visible: true
                        text: qsTr("You need to connect to a network to use this feature") +
                                   "<br><b>" + qsTr("Settings > System Settings > Wifi and Network") + "</b>"
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: statusImage
                        visible: true
                        source: "qrc:/img/process_error_small.png"
                    }
                }
            ]
        }
    }
}
