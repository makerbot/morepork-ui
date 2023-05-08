import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    id: userAssistedLoadInstructions

    ContentLeftSide {
        image {
            source: "qrc:/img/user_assisted_load.png"
            visible: true
        }
    }

    ContentRightSide {
        textHeader {
            text: qsTr("%1 REQUIRES MANUAL ASSISTANCE TO LOAD").arg(materialName)
            visible: true
        }

        textBody {
            text: qsTr("Remove the lid and swivel clip. Manually " +
                       "feed the material into the filament bay slot " +
                       "until it reaches the top. Push the material " +
                       "into the extruder until you feel it begin " +
                       "pulling.")
            visible: true
        }
    }
}
