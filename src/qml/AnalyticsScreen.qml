import QtQuick 2.10

AnalyticsScreenForm {
    enableDisableButton.button_mouseArea.onClicked: {
        if (bot.net.analyticsEnabled) {
            bot.setAnalyticsEnabled(false)
        } else {
            bot.setAnalyticsEnabled(true)
        }
    }
}
