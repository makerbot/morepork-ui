import QtQuick 2.12
import QtQuick.Layouts 1.9

Item {
    width: parent.width
    height: 104
    property string settingName: "default"
    property string settingText: "default"
    property alias editSettingButton: editSettingButton

//    width: dimensions["time_settings_button"]["width"]
//    height: dimensions["time_settings_button"]["height"]

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
        smooth: false
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.right: parent.right
        anchors.rightMargin: 40
        width: parent.width
        spacing: 32

        TextBody {
            text: settingName
            Layout.preferredWidth: 128
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        TextBody {
            font.weight: Font.Bold
            text: settingText
            Layout.preferredWidth: 408
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        ButtonRectangleSecondary {
            id: editSettingButton
            Layout.preferredWidth: 120
            text: qsTr("EDIT")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }
}
