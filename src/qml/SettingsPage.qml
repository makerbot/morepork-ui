import QtQuick 2.4
import ProcessTypeEnum 1.0

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

    buttonAdvancedInfo.onClicked: {
        settingsSwipeView.swipeToItem(5)
    }

    buttonResetToFactory.onClicked: {
        if(bot.process.type == ProcessType.None) {
            resetFactoryConfirmPopup.open()
        }
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
