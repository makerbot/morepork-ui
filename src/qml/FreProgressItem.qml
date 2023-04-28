import QtQuick 2.0

TextHeadline {
    id: text1
    enum State {
        Active,
        Enabled,
        Disabled
    }

    property int state: FreProgressItem.Active

    color: (state == FreProgressItem.Active || state == FreProgressItem.Enabled) ?
               "#ffffff" : "#595959"
    text: qsTr("SET UP")


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

