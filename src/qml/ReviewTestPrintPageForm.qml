import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    id: reviewTestPrintItem
    width: parent.width
    height: parent.height
    property alias continueButton: reviewPrintRightSide.buttonPrimary
    property alias calibrateButton: reviewPrintRightSide.buttonSecondary1

    // Make this overlay screen opaque to touches.
    MouseArea {
        id: emptyMouseArea
        z: -1
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    ContentLeftSide {
        id: image
        image.source: "qrc:/img/calib_verification.png"
        image.visible: true
    }

    ContentRightSide {
        id: reviewPrintRightSide

        textBody {
            text: qsTr("The support material should be centered inside the outer " +
                       "square and easily separated when the raft is removed. If not, " +
                       "run the extruder calibration again. For more detailed info visit")
            visible: true
        }

        textBody1 {
            text: "makerbot.com/calibration"
            font.weight: Font.Bold
            visible: true
        }

        buttonPrimary {
            text: qsTr("CONTINUE")
            visible: true
        }

        buttonSecondary1 {
            text: qsTr("RE-CALIBRATE")
            visible: true
        }
    }
}
