import QtQuick 2.10

AuthorizeAccountPageForm {
    buttonAuthorizeWithCode.onClicked: {
        authorizeAccountWithCodePage.beginAuthWithCode()
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.AuthorizeWithCode)
    }

    buttonLoginToMakerbotAccount.onClicked: {
        authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.AuthorizeWithCredentials)
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
        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
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

    Timer {
        id: closeAuthCompletePopupTimer
        interval: 5000
        onTriggered: {
            closePopup()
            backToSettings()
        }
    }
}
