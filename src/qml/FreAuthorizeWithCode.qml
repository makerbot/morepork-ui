import QtQuick 2.12

FreAuthorizeWithCodeForm {
    Timer {
        id: closePopupTimer
        interval: 3000
        onTriggered: {
            freAuthorizeWithCode_popup.close()
            if(authState == FreAuthorizeWithCode.Authorized) {
                fre.gotoNextStep(currentFreStep)
            }
            state = "base state"
        }
    }
    function beginAuthWithCode() {
        authState = FreAuthorizeWithCode.FetchingOTP
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
        authState = FreAuthorizeWithCode.Authorized
    }

    function getOTP(otp_arg, polling_token_arg) {
        authState = FreAuthorizeWithCode.WaitForAuthorized
        network.onInitiateAuthWithCodeSucceeded.disconnect(getOTP)
        otp = otp_arg
        polling_token = polling_token_arg
        var t = new Date()
        t.setMinutes(t.getMinutes() + 5)
        expires = t
        checkAuthTimer.start()
        expireOTPTimer.start()
    }

    function getOTPFailed() {
        disconnectHandlers()
        authState = FreAuthorizeWithCode.Failed
    }

    refreshOTP {
        button_mouseArea.onClicked: {
            beginAuthWithCode()
        }
    }

    continueButton {
        button_mouseArea.onClicked: {
            beginAuthWithCode()
        }
    }

    skipButton {
        button_mouseArea.onClicked: {
            skipFreStepPopup.open()
        }
    }
}
