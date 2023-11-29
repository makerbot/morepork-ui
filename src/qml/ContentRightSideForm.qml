import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    width: 400
    height: 408

    // Debug flag to help with development; set to true to
    // view the layout in design view with all elements and
    // pick the ones you want when designing a new page.
    property bool showAllElements: false
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        visible: showAllElements
    }

    property alias textHeader: textHeader
    property alias textHeaderWaitingForUser: textHeaderWaitingForUser
    property alias numberedSteps: numberedSteps
    property alias textBody: textBody
    property alias textBody1: textBody1
    property alias temperatureStatus: temperatureStatus
    property alias timeStatus: timeStatus
    property alias buttonPrimary: buttonPrimary
    property alias buttonSecondary1: buttonSecondary1
    property alias buttonSecondary2: buttonSecondary2
    property alias slidingSwitch: slidingSwitch

    anchors.right: parent.right
    anchors.bottom: parent.bottom

    ColumnLayout {
        width: 360
        anchors.verticalCenter: parent.verticalCenter
        spacing: 32

        ColumnLayout {
            Layout.preferredWidth: parent.width
            spacing: 24

            TextHeadline {
                id: textHeader
                style: TextHeadline.Base
                Layout.preferredWidth: parent.width
                text: "standard header"
                visible: false || showAllElements
            }

            TextHeadline {
                id: textHeaderWaitingForUser
                style: TextHeadline.Base
                text: "standard header"
                visible: false || showAllElements
                opacity: waitingForUser ? 0.7 : 1
                property bool waitingForUser: false

                Image {
                    id: waitingForUserImage
                    source: textHeaderWaitingForUser.waitingForUser ?
                                "qrc:/img/waiting_for_user.png" :
                                "qrc:/img/waiting_for_user_complete.png"
                    anchors.verticalCenter: textHeaderWaitingForUser.verticalCenter
                    anchors.left: textHeaderWaitingForUser.right
                    anchors.leftMargin: 24

                    RotationAnimator {
                        target: waitingForUserImage
                        from: 0
                        to: 360
                        direction: RotationAnimator.Clockwise
                        duration: 3000
                        loops: Animation.Infinite
                        running: textHeaderWaitingForUser.waitingForUser
                        onRunningChanged: {
                            waitingForUserImage.rotation = 0
                        }
                    }
                }
            }


            NumberedSteps {
                id: numberedSteps
                Layout.preferredWidth: parent.width
                steps: ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do"]
                activeSteps: [true, true, true]
                visible: false || showAllElements
            }

            TimeStatus {
                id: timeStatus
                visible: false || showAllElements
            }

            TextBody {
                id: textBody
                style: TextBody.Base
                font.weight: Font.Normal
                Layout.preferredWidth: parent.width
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id purus feugiat sed nisi, quam. Orci, in eu interdum erat purus, proin."
                visible: false || showAllElements
            }

            TextBody {
                id: textBody1
                style: TextBody.Base
                font.weight: Font.Bold
                Layout.preferredWidth: parent.width
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id purus feugiat sed nisi, quam. Orci, in eu interdum erat purus, proin."
                visible: false || showAllElements
            }

            TemperatureStatus {
                id: temperatureStatus
                visible: false || showAllElements
            }
        }

        ColumnLayout {
            spacing: 24

            ButtonRectanglePrimary {
                id: buttonPrimary
                text: "label"
                visible: false || showAllElements
            }

            ButtonRectangleSecondary {
                id: buttonSecondary1
                text: "label"
                visible: false || showAllElements
            }

            ButtonRectangleSecondary {
                id: buttonSecondary2
                text: "label"
                visible: false || showAllElements
            }

            SlidingSwitch {
                id: slidingSwitch
                showText: true
                switchText: "label"
                visible: false || showAllElements
            }
        }
    }
}
