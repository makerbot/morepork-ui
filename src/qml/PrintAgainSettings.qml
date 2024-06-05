import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    id: printAgainSettings

    ContentLeftSide {
        image {
            source: "qrc:/img/print_again_settings.png"
            visible: true
            opacity: bot.printAgainEnabled ? 1 : 0.3
        }
    }

    ContentRightSide {
        id: contentRightSide
        textBody {
            style: TextBody.Base
            text: qsTr("The “Print Again” option allows you to conveniently reprint the last job you started by saving the latest file on the printer.")
            visible: true
        }
        slidingSwitch {
            checked: bot.printAgainEnabled
            switchText: slidingSwitch.checked ? qsTr("Yes, please save the last print") :
                                                qsTr("No, do not save the last print")
            onClicked: {
                if(bot.printAgainEnabled) {
                    bot.setPrintAgainEnabled(false)
                } else {
                    bot.setPrintAgainEnabled(true)
                }
            }
            visible: true
        }
    }
}
