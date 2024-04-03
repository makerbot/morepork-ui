import QtQuick 2.12
import QtQuick.Layouts 1.3

LoggingItem {
    id: processStatusIcon
    itemName: "PrintIcon"
    width: 230
    height: 230

    enum Process {
        PrintProcess,
        GenericProcess
    }

    property int process: ProcessStatusIcon.GenericProcess

    enum Status {
        Loading,
        Running,
        Paused,
        Alert,
        Success,
        Failed
    }

    property int processStatus: ProcessStatusIcon.Loading

    property int processState: bot.process.stateType

    onProcessStateChanged: {
        progressRingCanvas.rotation = 0
        progressRingCanvas.requestPaint()
        centerStatusIcon.rotation = 0
    }

    Rectangle {
        id: progressCircleBase
        anchors.fill: parent
        radius: 115
        color: "#00000000"
        border.width: 20
        border.color: "#282828"

        Image {
            id: centerStatusIcon
            width: sourceSize.width
            height: sourceSize.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            smooth: true
            antialiasing: true

            source: "qrc:/img/loading_gear.png"
            visible: true

            property alias rotationAnimator: rotationAnimatorCenterIcon

            RotationAnimator {
                id: rotationAnimatorCenterIcon
                target: centerStatusIcon
                from: 360
                to: 0
                duration: 8000
                direction: RotationAnimator.Counterclockwise
                loops: Animation.Infinite
                running: false
            }
        }

        Canvas {
            id: progressRingCanvas
            anchors.fill: parent
            rotation : -90
            antialiasing: true
            smooth: true
            visible: true

            property int percent: bot.process.printPercentage
            onPercentChanged: requestPaint()

            property string progressRingColor: "#FFFFFF"

            onPaint: {
                rotation = -90
                var context = getContext("2d");
                context.reset();

                var centreX = parent.width*0.5;
                var centreY = parent.height*0.5;

                context.beginPath();
                //0.06283185 = PI*2/100
                context.arc(centreX, centreY, parent.width*0.5-10, 0,
                            percent*0.06283185, false);
                context.lineWidth = 20;
                context.lineCap = "round";
                context.strokeStyle = progressRingColor;
                context.stroke()
            }

            property alias rotationAnimator: rotationAnimatorProgressRing

            RotationAnimator {
                id: rotationAnimatorProgressRing
                target: progressRingCanvas
                from: 0
                to: 360
                duration: 8000
                direction: RotationAnimator.Clockwise
                loops: Animation.Infinite
                running: false
            }
        }

        TextHuge {
            id: progressPercentageText
            text: bot.process.printPercentage
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 8
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Light
            font.pixelSize: 100
            font.letterSpacing: 0
            lineHeight: 120
            visible: false

            TextBody {
                id: percentageSymbol
                text: "%"
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.left : parent.right
                anchors.leftMargin: -6
                font.weight: Font.Light
                font.pixelSize: 18
            }
        }
    }

    states: [
        State {
            name: "loading"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Loading

            PropertyChanges {
                target: centerStatusIcon
                source: "qrc:/img/loading_gear.png"
                rotationAnimator.running: true
                visible: true
            }

            PropertyChanges {
                target: progressRingCanvas
                percent: 25
                progressRingColor: "#FFFFFF" // White
                rotationAnimator.running: true
            }
        },

        State {
            name: "running"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Running

            PropertyChanges {
                target: centerStatusIcon
                rotationAnimator.running: false
                visible: false
            }

            PropertyChanges {
                target: progressRingCanvas
                progressRingColor: "#100AED" // Blue
                rotationAnimator.running: false
            }

            PropertyChanges {
                target: progressPercentageText
                visible: true
            }
        },

        State {
            name: "paused"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Paused

            PropertyChanges {
                target: centerStatusIcon
                rotationAnimator.running: false
                visible: false
            }

            PropertyChanges {
                target: progressRingCanvas
                progressRingColor: "#FFDD43" // Yellow
                rotationAnimator.running: false
            }

            PropertyChanges {
                target: progressPercentageText
                visible: true
            }
        },

        State {
            name: "success"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Success

            PropertyChanges {
                target: centerStatusIcon
                source: "qrc:/img/green_checkmark.png"
                rotation: 0
                rotationAnimator.running: false
                visible: true
            }

            PropertyChanges {
                target: progressRingCanvas
                percent: 100
                progressRingColor: "#00C84E" // Green
                rotationAnimator.running: false
            }
        },

        State {
            name: "alert"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Alert

            PropertyChanges {
                target: centerStatusIcon
                source: "qrc:/img/yellow_exclamation.png"
                rotation: 0
                rotationAnimator.running: false
                visible: true
            }

            PropertyChanges {
                target: progressRingCanvas
                percent: 100
                progressRingColor: "#FFDD43" // Yellow
                rotationAnimator.running: false
            }
        },

        State {
            name: "failed"
            when: process == ProcessStatusIcon.GenericProcess &&
                  processStatus == ProcessStatusIcon.Failed

            PropertyChanges {
                target: centerStatusIcon
                source: "qrc:/img/red_error.png"
                rotation: 0
                rotationAnimator.running: false
                visible: true
            }

            PropertyChanges {
                target: progressRingCanvas
                percent: 100
                progressRingColor: "#FF0021" // Red
                rotationAnimator.running: false
            }
        }
    ]
}
