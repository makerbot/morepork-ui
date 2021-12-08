import QtQuick 2.10
import QtQuick.Layouts 1.3

Rectangle {
    property alias button_rectangle: button_rectangle
    property alias button_text: button_text
    property alias button_mouseArea: button_mouseArea
    // buttonWidth is only used if forceButtonWidth is set to true
    property int buttonWidth: 100
    property alias buttonHeight: button_rectangle.height
    property alias label: button_text.text
    property int label_size: 21
    property bool disable_button: false
    property bool is_button_transparent: true
    property string button_pressed_color: "#ffffff"
    property string button_not_pressed_color: "#000000"
    property bool forceButtonWidth: false
    property bool selected: false
    property string key: ""

    id: button_rectangle
    width: forceButtonWidth ? buttonWidth : (button_text.contentWidth + 40)
    height: 50
    color: selected ? button_pressed_color : button_not_pressed_color
    radius: 8
    smooth: false
    antialiasing: false
    border.width: 2
    border.color: "#ffffff"
    opacity: disable_button ? 0.3 : 1
    // For elements used inside auto layout elements like ColumLayout,
    // RowLayout etc. the children's dimensions are controlled by the
    // layout element. To ovverride, preferredWidth and preferredHeight
    // properties need to be explicity set.
    Layout.preferredHeight: height
    Layout.preferredWidth: width

    property bool resetState: printStatusPage.failureFeedbackSelected
    onResetStateChanged: {
        if(resetState) {
            selected = false
        }
    }

    Text {
        id: button_text
        text: ""
        font.capitalization: Font.AllUppercase
        anchors.verticalCenterOffset: 7
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        color: selected ? button_not_pressed_color : button_pressed_color
        smooth: false
        antialiasing: false
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pixelSize: label_size
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        lineHeight: 1.5
    }

    LoggingMouseArea {
        logText: "FeedbackBtn: [(" + label + ")]"
        id: button_mouseArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height + 30
        smooth: false
        antialiasing: false
        preventStealing: true
        enabled: !disable_button
        onClicked: {
            if(selected) { selected = false }
            else { selected = true }
            updateFeedbackDict(key, selected)
        }
    }
}
