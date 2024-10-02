import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

SettingsPageForm {

    buttonSystemSettings.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
    }

    buttonExtruderSettings.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
    }

    buttonBuildPlateSettings.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.BuildPlateSettingsPage)
    }

    buttonCleanAirSettings.onClicked: {
        bot.getFilterHours()
        settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
    }

    buttonPreheat.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.PreheatPage)
    }

    buttonDryMaterial.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.DryMaterialPage)
    }

    buttonAnneal.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.AnnealPage)
    }

    buttonShutdown.onClicked: {
        shutdownPopup.open()
    }
}
