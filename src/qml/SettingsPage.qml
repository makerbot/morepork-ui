import QtQuick 2.4

SettingsPageForm {
    buttonChangeLanguage.onClicked: {
        settingsSwipeView.swipeToItem(1)
    }

    buttonAssistedLeveling.onClicked: {
        bot.assistedLevel()
        settingsSwipeView.swipeToItem(2)
    }

    buttonFirmwareUpdate.onClicked: {
        settingsSwipeView.swipeToItem(3)
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
