import QtQuick 2.10

SignInPageForm {
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
            bot.pause_touchlog()
            username = usernameTextField.text
            signInSwipeView.swipeToItem(SignInPage.PasswordPage)
            passwordField.forceActiveFocus()
        }
    }

    forgotPasswordButton {
        onClicked: {
            bot.pause_touchlog()
            showResetPasswordPopup()
            passwordField.forceActiveFocus()
        }
    }

    authorizeButton {
        button_mouseArea.onClicked: {
            var password = passwordField.text;
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
                network.onAuthWithCredentialsFailed.disconnect(getTokenFailed);
                network.onAuthWithCredentialsSucceeded.disconnect(getTokenSucceeded);
            }

            network.onAuthWithCredentialsFailed.connect(getTokenFailed);
            network.onAuthWithCredentialsSucceeded.connect(getTokenSucceeded);

            showAuthorizingPopup();
            network.authenticateWithCredentials(username, password);
        }
    }
}
