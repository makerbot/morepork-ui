import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    id: item1
    width: parent.width
    height: parent.height
    property alias continueButton: continue_button
    property alias calibrateButton: calibrate_button

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: image
        width: parent.width * 0.75
        height: parent.height * 0.75
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/calib_verification.png"
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent

        Text {
            id: text1
            width: 500
            color: "#cbcbcb"
            text: qsTr("The support material should be centered inside the outer space and easily\nseparated when the raft is removed. If not, run the extruder calibration again.\nFor more detailed info visit Makerbot.com/Calibration")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            font.family: "Antennae"
            font.pixelSize: 20
            lineHeight: 1.5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
        }

        Item {
            id: buttons_item
            anchors.fill: parent

            RoundedButton {
                id: calibrate_button
                buttonWidth: 280
                buttonHeight: 50
                label: qsTr("CALIBRATE AGAIN")
                visible: true
                anchors.left: parent.left
                anchors.leftMargin: 155
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
            }
            RoundedButton {
                id: continue_button
                buttonWidth: 170
                buttonHeight: 50
                label: qsTr("CONTINUE")
                visible: true
                anchors.right: parent.right
                anchors.rightMargin: 155
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
            }
        }
    }
}
