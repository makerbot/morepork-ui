import QtQuick 2.10

AuthorizeAccountPageForm {
    buttonAuthorizeWithCode.onClicked: {
        if(!isNetworkConnectionAvailable) {
            showNoNetworkConnectionPopup()
            return
        }
        authorizeAccountWithCodePage.beginAuthWithCode()
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.AuthorizeWithCode)
    }

    buttonLoginToMakerbotAccount.onClicked: {
        if(!isNetworkConnectionAvailable) {
            showNoNetworkConnectionPopup()
            return
        }
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.AuthorizeWithCredentials)
    }

    buttonDeauthorizeAccounts.onClicked: {
        if(!isNetworkConnectionAvailable) {
            showNoNetworkConnectionPopup()
            return
        }
        showDeauthorizePopup()
    }

    function backToSelectAuthMethod() {
        closePopup()
        authorizeAccountWithCodePage.checkAuthTimer.stop()
        authorizeAccountWithCodePage.expireOTPTimer.stop()
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
    }

    function backToSettings() {
        signInPage.usernameTextField.clear()
        signInPage.passwordField.clear()
        signInPage.showPassword.checked = false
        signInPage.signInSwipeView.swipeToItem(SignInPage.BasePage)
        authorizeAccountWithCodePage.checkAuthTimer.stop()
        authorizeAccountWithCodePage.expireOTPTimer.stop()
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.ChooseAuthMethod)
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
    }

    function closePopup() {
        authorizeAccountPopup.close()
    }

    function showAuthorizingPopup() {
        authorizeAccountPopup.state = "authorizing"
        authorizeAccountPopup.open()
    }

    function showConnectingPopup() {
        authorizeAccountPopup.state = "connecting_to_get_otp"
        authorizeAccountPopup.open()
    }

    function showFailedToConnectPopup() {
        authorizeAccountPopup.state = "failed_to_get_otp"
        authorizeAccountPopup.open()
    }

    function showNoAccountPopup() {
        authorizeAccountPopup.state = "no_account"
        authorizeAccountPopup.open()
    }

    function showResetPasswordPopup() {
        authorizeAccountPopup.state = "reset_password"
        authorizeAccountPopup.open()
    }

    function showSignInFailedPopup() {
        authorizeAccountPopup.state = "authorization_failed"
        authorizeAccountPopup.open()
    }

    function showSignInSucceededPopup() {
        authorizeAccountPopup.state = "authorization_successful"
        authorizeAccountPopup.open()
        closeAuthCompletePopupTimer.start()
    }

    function showDeauthorizePopup() {
        authorizeAccountPopup.state = "deauthorize_accounts"
        authorizeAccountPopup.open()
    }

    function showNoNetworkConnectionPopup() {
        authorizeAccountPopup.state = "no_network_connection"
        authorizeAccountPopup.open()
    }

    Timer {
        id: closeAuthCompletePopupTimer
        interval: 5000
        onTriggered: {
            closePopup()
            backToSettings()
            if (inFreStep) {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
        }
    }
}
