import QtQuick 2.10

AuthorizeAccountWithCodeForm {
    function beginAuthWithCode() {
        bot.handshake()
        showConnectingPopup()
        network.onInitiateAuthWithCodeSucceeded.connect(getOTP)
        network.onCheckAuthWithCodeSucceeded.connect(authorized)
        network.onInitiateAuthWithCodeFailed.connect(getOTPFailed)
        network.initiateAuthWithCode(bot.iserial, bot.name, bot.type, bot.net.ipAddr)
    }

    function disconnectHandlers() {
        network.onInitiateAuthWithCodeSucceeded.disconnect(getOTP)
        network.onInitiateAuthWithCodeFailed.disconnect(getOTPFailed)
        network.onCheckAuthWithCodeSucceeded.disconnect(authorized)
    }

    function authorized(username, oauth_token) {
        disconnectHandlers()
        checkAuthTimer.stop()
        bot.addMakerbotAccount(username, oauth_token);
        authorizeAccountPage.username = username
        showSignInSucceededPopup();
    }

    function getOTP(otp, polling_token) {
        authorizeAccountWithCodePage.otp_expired = false
        closePopup()
        network.onInitiateAuthWithCodeSucceeded.disconnect(getOTP)
        authorizeAccountWithCodePage.otp = otp
        authorizeAccountWithCodePage.polling_token = polling_token
        var t = new Date()
        t.setMinutes(t.getMinutes() + 5)
        authorizeAccountWithCodePage.expires = t
        checkAuthTimer.start()
        expireOTPTimer.start()
    }

    function getOTPFailed() {
        disconnectHandlers()
        showFailedToConnectPopup()
    }

    getOTPButton {
        button_mouseArea.onClicked: {
            beginAuthWithCode()
        }
    }
}
