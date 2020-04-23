import QtQuick 2.10

AuthorizeAccountPageForm {
    buttonAuthorizeWithCode.onClicked: {
        authorizeAccountWithCodePage.beginAuthWithCode()
        authorizeAccountSwipeView.swipeToItem(1)
    }

    buttonLoginToMakerbotAccount.onClicked: {
        authorizeAccountSwipeView.swipeToItem(2)
    }

    function backToSelectAuthMethod() {
        closePopup()
        authorizeAccountWithCodePage.checkAuthTimer.stop()
        authorizeAccountWithCodePage.expireOTPTimer.stop()
        authorizeAccountSwipeView.swipeToItem(0)
    }

    function backToSettings() {
        signInPage.usernameTextField.clear()
        signInPage.passwordField.clear()
        signInPage.showPassword.checked = false
        signInPage.signInSwipeView.swipeToItem(0)
        authorizeAccountWithCodePage.checkAuthTimer.stop()
        authorizeAccountWithCodePage.expireOTPTimer.stop()
        authorizeAccountSwipeView.swipeToItem(0)
        settingsSwipeView.swipeToItem(0)
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
        if(inFreStep) {
            signInFreStepComplete.start()
        } else {
            closeAuthCompletePopupTimer.start()
        }
    }

    Timer {
        id: signInFreStepComplete
        interval: 5000
        onTriggered: {
            closePopup()
            backToSettings()
            mainSwipeView.swipeToItem(0)
            fre.gotoNextStep(currentFreStep)
        }
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
