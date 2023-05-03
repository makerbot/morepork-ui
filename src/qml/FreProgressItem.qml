import QtQuick 2.0

Text {
    id: text1
    enum State {
        Active,
        Enabled,
        Disabled
    }

    property int state: FreProgressItem.Active

    color: (state == FreProgressItem.Active || state == FreProgressItem.Enabled) ?
               "#ffffff" : "#595959"
    text: qsTr("SETUP")
    font.family: "Antenna"
    font.pixelSize: 17
    font.weight: Font.DemiBold
    font.letterSpacing: 3.2
    font.capitalization: Font.AllUppercase
    lineHeightMode: Text.FixedHeight
    lineHeight: 20

    Rectangle {
        id: circle_indicator
        width: 14
        height: 14
        color: parent.color
        radius: 7
        visible: (parent.state == FreProgressItem.Active)
        anchors.right: parent.left
        anchors.rightMargin: 18
    }
}

