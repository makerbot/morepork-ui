import QtQuick 2.5

Item {
    id: button
    width: 30
    height: 30
    property alias buttonText: innerText.text
    property color color: "white"
    property color pressColor: "slategray"
    property int fontSize: 10
    property int borderWidth: 1
    property int borderRadius: 2
    scale: state === "Pressed" ? 0.96 : 1.0
    onEnabledChanged: state = ""
    signal clicked

    //define a scale animation
    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    //Rectangle to draw the button
    Rectangle {
        id: rectangleButton
        anchors.fill: parent
        radius: button.borderRadius
        color: button.color
        border.width: button.borderWidth
        border.color: "black"

        Text {
            id: innerText
            font.pointSize: button.fontSize
            anchors.centerIn: parent
        }
    }

    //change the color of the button in differen button states
    states: [
        State {
            name: "Pressed"
            PropertyChanges {
                target: rectangleButton
                color: button.pressColor
            }
        }
    ]

    //define transmission for the states
    transitions: [
        Transition {
            from: "*"
            to: "Pressed"
            ColorAnimation {
                duration: 10
            }
        }
    ]

    //Mouse area to react on click events
    MouseArea {
        hoverEnabled: true
        anchors.fill: button
        onClicked: {
            button.clicked()
        }
        onPressed: {
            button.state = "Pressed"
        }
        onReleased: {
            button.state = ""
        }
    }
}
