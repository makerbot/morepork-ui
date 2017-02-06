import QtQuick 2.5
import QtQuick.Controls 2.0

Rectangle {
    width: 440
    height: 800

    TextField {
        id: nameField
        x: 142
        y: 8
        width: 290
        height: 40
        placeholderText: bot.name
        onEditingFinished: bot.name = nameField.text
    }

    Label {
        id: nameLabel
        x: 8
        y: 8
        width: 128
        height: 40
        text: qsTr("Machine Name")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    TextField {
        id: ipField
        x: 142
        y: 54
        width: 290
        height: 40
        placeholderText: bot.net.ipAddr
        onEditingFinished: bot.net.ipAddr = ipField.text
    }

    Label {
        id: ipLabel
        x: 8
        y: 54
        width: 128
        height: 40
        text: qsTr("IP Address")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

}
