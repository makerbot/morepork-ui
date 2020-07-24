import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

CheckBox {
    property alias checkbox_text: checkboxText.text
    checked: false
    Text {
        id: checkboxText
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.top: parent.top
        anchors.topMargin: 10
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 12
        font.capitalization: Font.AllUppercase
        smooth: false
        text: ""
        color: "white"
    }
}
