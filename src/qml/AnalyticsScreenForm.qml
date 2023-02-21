import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 420

    Image {
        width: sourceSize.width
        height: sourceSize.height
        anchors.right: contentRightSide.left
        anchors.rightMargin: 136
        anchors.verticalCenter: contentRightSide.verticalCenter
        source: "qrc:/img/analytics_makerbot_logo.png"
        opacity: bot.net.analyticsEnabled ? 1 : 0.3
    }

    ContentRightSide {
        id: contentRightSide
        textHeader{
            text: qsTr("MAKERBOT ANALYTICS")
            visible: true
        }
        textBody {
            style: TextBody.Large
            text: qsTr("Analytics enables sharing of information about your 3D printer with MakerBot to help us improve our products.")
            visible: true
        }
        slidingSwitch {
            checked: bot.net.analyticsEnabled
            switchText: slidingSwitch.checked ? qsTr("Analytics Enabled") : qsTr("Analytics Disabled")
            onClicked: {
                if(bot.net.analyticsEnabled) {
                    bot.setAnalyticsEnabled(false)
                } else {
                    bot.setAnalyticsEnabled(true)
                }
            }
            visible: true
        }
    }
}
