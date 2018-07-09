import QtQuick 2.7

SignInPageForm {
    function backToSettings() {
        usernameTextField.clear();
        passwordField.clear();
        showPassword.checked = false;
        signInSwipeView.swipeToItem(0);
        settingsSwipeView.swipeToItem(0);
    }

    function closePopup() {
        signInPagePopup.close();
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
    }

    addAccountButton {
        button_mouseArea.onClicked: {
            signInSwipeView.swipeToItem(1);
        }
    }

    noAccountButton {
        onClicked: {
            showNoAccountPopup();
        }
    }

    enteredUsernameButton {
        button_mouseArea.onClicked: {
            username = usernameTextField.text;
            signInSwipeView.swipeToItem(2);
        }
    }

    forgotPasswordButton {
        onClicked: {
            showResetPasswordPopup();
        }
    }

    authorizeButton {
        button_mouseArea.onClicked: {
            var password = passwordField.text;
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

                            // Soooo, ideally this should wait until we actually
                            // got a success response back from kaiten first
                            // before showing the success popup, but I don't
                            //think we really do that for any other jsonrpc
                            // calls, and that infrastructure should really be
                            // codegen'd, so until that happens, it's probably
                            // okay to just leave this like so..?
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
        }
    }
}
