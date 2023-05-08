import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    id: labsExtruderLoadingInstructions

    ContentLeftSide {
        image {
            source: "qrc:/img/labs_extruder_instructions.png"
            visible: true
        }
    }

    ContentRightSide {
        textHeader {
            text: qsTr("FEED MATERIAL THROUGH AUX PORT 1")
            visible: true
        }

        textBody {
            text: qsTr("Remove the cover on the top left of the " +
                       "printer and feed material into AUX port " +
                       "1. Keep feeding until you feel it pulled " +
                       "in by the extruder.")
            visible: true
        }
    }
}
