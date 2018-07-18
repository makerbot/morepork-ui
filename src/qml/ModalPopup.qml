import QtQuick 2.4

ModalPopupForm {

    function setPopupContents(contentsComponent,
                              button1_text,
                              button2_text,
                              disable_user_close) {
        var obj = contentsComponent.createObject(popup_contents);
        popup_contents.contentItem = obj;

        if (button1_text && button2_text) {
            setTwoButtonsVisible(true);
            setTwoButtonText(button1_text, button2_text);
            setButtonBarVisible(true);
        } else if (button1_text) {
            setTwoButtonsVisible(false);
            setSingleButtonText(button1_text);
            setButtonBarVisible(true);
        } else {
            setButtonBarVisible(false);
        }
        disableUserClose = !!disable_user_close;
    }

    function setTwoButtonText(leftText, rightText) {
        left_text.text = leftText;
        right_text.text = rightText;
    }

    function setSingleButtonText(text) {
        full_button_text.text = text;
    }

    function setTwoButtonsVisible(visible) {
        showTwoButtons = visible;
    }

    function setButtonBarVisible(visible) {
        showButtonBar = visible;
    }

    // TODO: might not need these?
    function setButtonOnClicked(button, func) {
        button.onClicked.connect(func);
    }

    function setLeftButtonOnClicked(func) {
        setButtonOnClicked(left_mouseArea, func);
    }

    function setRightButtonOnClicked(func) {
        setButtonOnClicked(right_mouseArea, func);
    }

    function setSingleButtonOnClicked(func) {
        setButtonOnClicked(full_button_mouseArea, func);
    }
}
