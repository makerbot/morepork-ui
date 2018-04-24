import QtQuick 2.4

SettingsPageForm {
    buttonChangeLanguage.onClicked: {
        settingsSwipeView.swipeToItem(1)
    }

    buttonAssistedLeveling.onClicked: {
        settingsSwipeView.swipeToItem(2)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        settingsSwipeView.swipeToItem(3)
    }

    buttonCalibrateToolhead.onClicked: {
        settingsSwipeView.swipeToItem(4)
    }

    buttonEnglish.onClicked: {
        cpUiTr.selectLanguage("en")
    }

    buttonSpanish.onClicked: {
        cpUiTr.selectLanguage("es")
    }

    buttonFrench.onClicked: {
        cpUiTr.selectLanguage("fr")
    }

    buttonItalian.onClicked: {
        cpUiTr.selectLanguage("it")
    }
}
