import QtQuick 2.10

SignInPageForm {
    function backToSettings() {
        usernameTextField.clear()
        passwordField.clear()
        showPassword.checked = false
        signInSwipeView.swipeToItem(SignInPage.BasePage)
        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
    }

    function closePopup() {
        signInPagePopup.close()
    }

    function showAuthorizingPopup() {
        var p = signInPagePopup;
        p.setButtonBarVisible(false);
        p.setPopupContents(authorizingContents, null, null, true);
        p.open();
    }

    function showNoAccountPopup() {
        var p = signInPagePopup;
        p.setPopupContents(noAccountContents, "DONE");
        p.setSingleButtonOnClicked(closePopup);
        p.open();
    }

    function showResetPasswordPopup() {
        var p = signInPagePopup;
        p.setPopupContents(resetPasswordContents, "DONE");
        p.setSingleButtonOnClicked(closePopup);
        p.open();
    }

    function showSignInFailedPopup() {
        var p = signInPagePopup;
        p.setPopupContents(signInFailedContents, "TRY AGAIN");
        p.setSingleButtonOnClicked(closePopup);
        p.open();
    }

    function showSignInSucceededPopup() {
        var p = signInPagePopup;
        p.setButtonBarVisible(false);
        p.setPopupContents(signInSucceededContents);
        p.open();
        if(inFreStep) {
            signInFreStepComplete.start()
        } else {
            closeAuthCompletePopupTimer.start()
        }
    }

    Timer {
        id: signInFreStepComplete
        interval: 3000
        onTriggered: {
            closePopup()
            backToSettings()
            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            fre.gotoNextStep(currentFreStep)
        }
    }

    Timer {
        id: closeAuthCompletePopupTimer
        interval: 3000
        onTriggered: {
            closePopup()
            backToSettings()
        }
    }

    addAccountButton {
        button_mouseArea.onClicked: {
            signInSwipeView.swipeToItem(SignInPage.UsernamePage)
            usernameTextField.forceActiveFocus()
        }
    }

    noAccountButton {
        onClicked: {
            showNoAccountPopup()
            usernameTextField.forceActiveFocus()
        }
    }

    enteredUsernameButton {
        button_mouseArea.onClicked: {
            username = usernameTextField.text
            signInSwipeView.swipeToItem(SignInPage.PasswordPage)
            passwordField.forceActiveFocus()
        }
    }

    forgotPasswordButton {
        onClicked: {
            showResetPasswordPopup()
            passwordField.forceActiveFocus()
        }
    }

    authorizeButton {
        button_mouseArea.onClicked: {
            var password = passwordField.text;

            // Not sure if we want to switch back to using this (and get rid of
            // the Network class that we're using as a workaround) if we're able
            // to get this to work on the bot? This seems to be the standard way
            // of http requests on the qml side...? If we don't care to switch,
            // then delete all of this.

            /*
            var http = new XMLHttpRequest();
            http.open(
                    "POST",
                    "https://staging.thingiverse.com/login/oauth/access_token",
                    true);
            http.setRequestHeader(
                    "Content-Type",
                    "application/x-www-form-urlencoded")

            var data =
                "client_id=682cb30bf432d934dee3&" +
                "client_secret=76bd0530229cc606949811c7c438a698&" +
                "username=" + username +
                "&password=" + password +
                "&grant_type=password";

            http.onreadystatechange = function () {
                if (http.readyState == 4) {  // (DONE)
                    if (http.status == 200) {
                        var token = ""
                        try {
                            // expect response that looks like this:
                            // `access_token=(token)&token_type=Bearer`
                            token =
                                http.responseText.split("&")[0].split("=")[1];
                            bot.addMakerbotAccount(username, token);

                            showSignInSucceededPopup();
                        } catch(err) {
                            console.log(err);
                            console.log(
                                "Received unexpected response: " +
                                http.responseText);
                            showSignInFailedPopup();
                        }
                    } else {
                        showSignInFailedPopup();
                        console.log(http.responseText);
                    }
                }
            }

            http.send(data);
            showAuthorizingPopup();
            */

            // set up signal handlers
            function getTokenFailed() {
                showSignInFailedPopup();
                disconnectGetTokenHandlers();
            }
            function getTokenSucceeded(token) {
                bot.addMakerbotAccount(username, token);

                // Soooo, ideally this should wait until we actually
                // got a success response back from kaiten first
                // before showing the success popup, but I don't
                // think we really do that for any other jsonrpc
                // calls, and that infrastructure should really be
                // codegen'd, so until that happens, it's probably
                // okay to just leave this like so..?
                showSignInSucceededPopup();
                disconnectGetTokenHandlers();
            }
            function disconnectGetTokenHandlers() {
                network.onGetMakerBotTokenFailed.disconnect(getTokenFailed);
                network.onGetMakerBotTokenFinished.disconnect(getTokenSucceeded);
            }

            network.onGetMakerBotTokenFailed.connect(getTokenFailed);
            network.onGetMakerBotTokenFinished.connect(getTokenSucceeded);

            showAuthorizingPopup();
            network.GetMakerBotToken(username, password);
        }
    }
}
