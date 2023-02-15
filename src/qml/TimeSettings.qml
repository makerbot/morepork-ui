import QtQuick 2.12
import QtQuick.Layouts 1.3

Item {
    anchors.fill: parent
    Column {
        anchors.fill: parent
        MenuButton {
            buttonText {
                text: qsTr("SHOW CURRENT TIME")
            }
            slidingSwitch {
                visible: true
                checked: settings.getShowTimeInTopBar()
                onClicked: {
                    settings.setShowTimeInTopBar(slidingSwitch.checked)
                    showTime(slidingSwitch.checked)
                }
            }
        }

        TimeSettingsButton {
            settingName: qsTr("Time Zone")
            settingText: {
                bot.timeZone
            }
            editSettingButton.onClicked: {
                timeSwipeView.swipeToItem(TimePage.SetTimeZone)
            }
        }

        TimeSettingsButton {
            settingName: qsTr("Current Date")
            settingText: timeSelectorPage.displayDate
            editSettingButton.onClicked: {
                timeSwipeView.swipeToItem(TimePage.SetDate)
            }
        }

        TimeSettingsButton {
            settingName: qsTr("Current Time")
            settingText: timeSelectorPage.displayTime
            editSettingButton.onClicked: {
                timeSwipeView.swipeToItem(TimePage.SetTime)
            }
        }
    }
}
