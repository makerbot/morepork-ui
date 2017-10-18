import QtQuick 2.4
Item {
    id: item1
    width: 400
    height: 400
    property alias action_mouseArea: action_mouseArea
    property alias percentage_printing_text: percentage_printing_text
    property alias status_image: status_image
    property alias loading_or_paused_image: loading_or_paused_image
    property alias canvas: canvas
    property alias progress_circle: progress_circle

    Rectangle {
        id: rectangle
        width: 400
        height: 400
        color: "#000000"
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: base_circle
            x: 75
            y: 75
            width: 250
            height: 250
            color: "#000000"
            radius: 125
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            border.width: 3
            border.color: "#484848"

            Rectangle {
                id: progress_circle
                x: 13
                y: 13
                width: 224
                height: 224
                color: "#00000000"
                radius: 112
                border.color: "#00000000"
                border.width: 0
                rotation: -90
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                property int percent: print_percentage

                onPercentChanged: canvas.requestPaint()
                Canvas {
                    id: canvas
                    anchors.fill: parent
                    onPaint:
                    {
                        var context = getContext("2d");
                        context.reset();

                        var centreX = parent.width / 2;
                        var centreY = parent.height / 2;

                        context.beginPath();
                        context.fillStyle = "#3183AF";
                        context.moveTo(centreX, centreY);
                        context.arc(centreX, centreY, parent.width / 2,  (Math.PI*0), (Math.PI*(2.0*print_percentage/100)), false);
                        context.lineTo(centreX, centreY);
                        context.fill();
                    }
                }
            }

            Rectangle {
                id: inner_circle
                x: 21
                y: 21
                width: 207
                height: 207
                color: "#000000"
                radius: 104
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: true
            }
        }

        Image {
            id: status_image
            x: 150
            y: 150
            width: 68
            height: 68
            source: "qrc:/img/loading_gears.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            RotationAnimator {
                    target: status_image;
                    alwaysRunToEnd: true
                    from: 360000;
                    to: 0;
                    duration: 10000000
                    running: current_state == 1 ? true : false
                }
        }

        Image {
            id: loading_or_paused_image
            width: 214
            height: 214
            source: "qrc:/img/loading_rings.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            RotationAnimator {
                    target: loading_or_paused_image;
                    alwaysRunToEnd: true
                    from: 0;
                    to: 360000;
                    duration: 10000000
                    running: (current_state == 1 || 3) ? true : false
                }
        }



        Text {
            id: percentage_printing_text
            x: 152
            y: 156
            color: "#ffffff"
            text: print_percentage
            anchors.verticalCenterOffset: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            visible: false
            font.family: "Antenna"
            font.weight: Font.Light
            font.pixelSize: 75

            Text {
                id: percentage_symbol_text
                color: "#ffffff"
                text: qsTr("%")
                anchors.top: parent.top
                anchors.topMargin: 2
                visible: false
                anchors.right: parent.right
                anchors.rightMargin: -30
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Antenna"
                font.weight: Font.Light
                font.pixelSize: 25
            }
        }

        Rectangle {
            id: action_circle
            x: 175
            y: 291
            width: 60
            height: 60
            color: "#000000"
            radius: 30
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 55
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            border.width: 3
            border.color: "#484848"

            Image {
                id: action_image
                source: "qrc:/qtquickplugin/images/template_image.png"
            }

            MouseArea {
                id: action_mouseArea
                width: 50
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

    }
    states: [
        State {
            name: "printing_state"; when: current_state == 2

            PropertyChanges {
                target: status_image
                visible: false
            }

            PropertyChanges {
                target: loading_or_paused_image
                visible: false
            }

            PropertyChanges {
                target: action_circle
                width: 61
                height: 61
                visible: true
            }

            PropertyChanges {
                target: percentage_printing_text
                visible: true
            }

            PropertyChanges {
                target: progress_circle
                visible: true
            }

            PropertyChanges {
                target: percentage_symbol_text
                visible: true
            }

            PropertyChanges {
                target: action_image
                x: 8
                y: 8
                width: 45
                height: 45
                anchors.rightMargin: 8
                anchors.bottomMargin: 8
                anchors.topMargin: 8
                anchors.leftMargin: 8
                source: "qrc:/img/pause.png"
            }
        },
        State {
            name: "paused_state"; when: current_state == 3

            PropertyChanges {
                target: status_image
                visible: false
            }

            PropertyChanges {
                target: action_circle
                width: 61
                height: 61
                radius: 30
                visible: true
            }

            PropertyChanges {
                target: percentage_printing_text
                visible: true
            }

            PropertyChanges {
                target: progress_circle
                visible: false
            }

            PropertyChanges {
                target: loading_or_paused_image
                width: 214
                height: 214
                source: "qrc:/img/paused_rings.png"
            }

            PropertyChanges {
                target: action_image
                x: 8
                y: 8
                width: 45
                height: 45
                source: "qrc:/img/play.png"
            }

            PropertyChanges {
                target: percentage_symbol_text
                visible: true
            }

        },
        State {
            name: "print_complete_state"; when: current_state == 4

            PropertyChanges {
                target: loading_or_paused_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                visible: true
            }
            PropertyChanges {
                target: status_image
                width: 79
                height: 59
                source: "qrc:/img/check_mark.png"
                visible: true
            }

        }
    ]
}
