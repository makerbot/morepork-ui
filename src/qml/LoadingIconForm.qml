import QtQuick 2.10

Rectangle {
    id: loading_icon
    width: 250
    height: 250
    color: "#00000000"
    radius: 125
    border.width: 3
    border.color: "#484848"
    antialiasing: true
    smooth: true
    visible: true

    enum Icon {
        Loading,
        Progress,
        Success,
        Failure
    }

    property int icon_image: LoadingIcon.Loading
    property alias loading: loading_icon.visible
    property int loadingProgress: 0

    Image {
        id: inner_image
        width: 68
        height: 68
        smooth: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/loading_gears.png"

        RotationAnimator {
            id: rotate_inner_image
            target: inner_image
            from: 360
            to: 0
            duration: 10000
            loops: Animation.Infinite
            running: icon_image == LoadingIcon.Loading
        }
    }

    Image {
        id: outer_image
        width: 214
        height: 214
        smooth: false
        source: "qrc:/img/loading_rings.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        RotationAnimator {
            target: outer_image
            from: 0
            to: 360
            duration: 10000
            loops: Animation.Infinite
            running: true
        }
    }

    Rectangle {
        id: progress_circle
        width: 240
        height: 240
        color: "#00000000"
        radius: 120
        antialiasing: true
        smooth: true
        border.width: 3
        border.color: "#FFFFFF"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: progress_text
        color: "#ffffff"
        text: loadingProgress
        antialiasing: false
        smooth: false
        anchors.verticalCenterOffset: 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 75

        Text {
            id: percentage_symbol_text
            color: "#ffffff"
            text: "%"
            antialiasing: false
            smooth: false
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: -30
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 25
        }
    }

    onLoadingProgressChanged: canvas.requestPaint()
    Canvas {
        id: canvas
        antialiasing: false
        smooth: false
        rotation : -90
        anchors.fill: parent
        onPaint: {
            var context = getContext("2d");
            context.reset();

            var centreX = parent.width*0.5;
            var centreY = parent.height*0.5;

            context.beginPath();
            //0.06283185 = PI*2/100
            context.arc(centreX, centreY, parent.width*0.5-15, 0,
                        parent.loadingProgress*0.06283185, false);
            context.lineWidth = 10;
            context.lineCap = "round";
            context.strokeStyle = "#FFFFFF";
            context.stroke()
        }
    }
    states: [

        State {
            name: "loading"
            when: icon_image === LoadingIcon.Loading

            PropertyChanges {
                target: inner_image
                source: "qrc:/img/loading_gears.png"
                visible: true
                width: 68
                height: 68
            }

            PropertyChanges {
                target: outer_image
                visible: true
            }

            PropertyChanges {
                target: progress_circle
                visible: false
            }

            PropertyChanges {
                target: progress_text
                visible: false
            }

            PropertyChanges {
                target: canvas
                visible: false
            }

        },
        State {
            name: "progress"
            when: icon_image === LoadingIcon.Progress

            PropertyChanges {
                target: inner_image
                visible: false
            }

            PropertyChanges {
                target: outer_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                visible: false
            }

            PropertyChanges {
                target: progress_text
                visible: true
            }

            PropertyChanges {
                target: canvas
                visible: true
            }

        },
        State {
            name: "success"
            when: icon_image === LoadingIcon.Success


            PropertyChanges {
                target: inner_image
                source: "qrc:/img/check_mark.png"
                visible: true
                rotation: 0
                width: 79
                height: 59
            }

            PropertyChanges {
                target: outer_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                border.color: "#3183AF"
                visible: parent.visible
            }

            PropertyChanges {
                target: progress_text
                visible: false
            }

            PropertyChanges {
                target: canvas
                visible: false
            }

        },
        State {
            name: "failure"
            when: icon_image === LoadingIcon.Failure


            PropertyChanges {
                target: inner_image
                source: "qrc:/img/exc_mark.png"
                visible: true
                rotation: 0
                width: 16
                height: 89
            }

            PropertyChanges {
                target: outer_image
                visible: false
            }

            PropertyChanges {
                target: progress_circle
                border.color: "#F79125"
                visible: parent.visible
            }

            PropertyChanges {
                target: progress_text
                visible: false
            }

            PropertyChanges {
                target: canvas
                visible: false
            }
        }
    ]
}
