import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
Item {

    enum Style {
        Button,
        ButtonWithHelp
    }

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

    property int style: ContentRightSideForm.Button
    property bool isCompleted: false

    property alias textHeader: textHeader
    property alias textHeader1: textHeader1
    property alias textHeader1Loading: textHeader1Loading
    property alias numberedSteps: numberedSteps
    property alias textBody: textBody
    property alias textBody1: textBody1
    property alias temperatureStatus: temperatureStatus
    property alias buttonPrimary: buttonPrimary
    property alias buttonSecondary1: buttonSecondary1
    property alias buttonSecondary2: buttonSecondary2
    property alias slidingSwitch: slidingSwitch
    property alias help: helpButton

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
                id: textHeader1
                style: TextHeadline.Base
                text: "standard header"
                visible: false || showAllElements

                Item{
                    id: textHeader1Loading
                    visible: false || showAllElements
                    anchors.verticalCenter: textHeader1.verticalCenter
                    anchors.left: textHeader1.right
                    anchors.leftMargin: 25
                    height: 21
                    width: 21

                    Image{
                        source: "qrc:/img/popup_complete.png"
                        anchors.verticalCenter: textHeader1.verticalCenter
                        anchors.left: textHeader1.right
                        sourceSize.height: 21
                        sourceSize.width: 21
                        visible: isCompleted
                    }
                    AnimatedImage{
                        source: "qrc:/img/attach_extruder_loading.gif"
                        anchors.verticalCenter: textHeader1.verticalCenter
                        anchors.left: textHeader1.right
                        anchors.leftMargin: 25
                        visible: !isCompleted
                        playing: true
                        height: 21
                        width: 21
                    }
                }
            }


            NumberedSteps {
                id: numberedSteps
                Layout.preferredWidth: parent.width
                steps: ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do"]
                inactiveSteps: [false, false, false]
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

            RowLayout {
                Layout.preferredWidth: 360
                ButtonRectanglePrimary {
                    id: buttonPrimary
                    text: "label"
                    Layout.preferredWidth: helpButton.visible ? 318 : 360
                    visible: false || showAllElements
                }

                Button {
                    id: helpButton
                    Layout.preferredWidth: 32
                    antialiasing: false
                    smooth: false
                    flat: true
                    visible: style == ContentRightSideForm.ButtonWithHelp || showAllElements
                    enabled: true

                    contentItem: Item {
                        Image {
                            source: "qrc:/img/button_help.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter

                            Behavior on opacity {
                                OpacityAnimator {
                                    duration: 100
                                }
                            }
                        }
                    }
                    Component.onCompleted: {
                        this.onReleased.connect(logClick)
                    }

                    function logClick() {
                        console.info(" Help clicked")
                    }
                }


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
