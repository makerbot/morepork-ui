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
        width: parent.width
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -30
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/calib_verification.png"
    }

    ColumnLayout {
        id: columnLayout
        anchors.top: image.top
        anchors.topMargin: 285
        anchors.horizontalCenter: parent.horizontalCenter
        height: children.height
        spacing: 20

        Text {
            id: text1
            Layout.maximumWidth: 700
            color: "#cbcbcb"
            text: qsTr("The support material should be centered inside the outer square and easily separated when the raft is removed. If not, run the extruder calibration again. For more detailed info visit Makerbot.com/Calibration")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.pixelSize: 20
            lineHeight: 1.3
        }

        RowLayout {
            id: buttonsContainer
            spacing: 50
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            RoundedButton {
                id: calibrate_button
                buttonWidth: 280
                buttonHeight: 50
                label: qsTr("CALIBRATE AGAIN")
                visible: true
            }

            RoundedButton {
                id: continue_button
                buttonWidth: 170
                buttonHeight: 50
                label: qsTr("CONTINUE")
                visible: true
            }
        }
    }
}
