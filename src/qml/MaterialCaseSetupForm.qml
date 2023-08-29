import QtQuick 2.12
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

LoggingItem {
    itemName: "SunflowerUnpacking"
    anchors.fill: parent
    property alias continueButton: caseSetupContentRightSide.buttonPrimary

    ContentLeftSide {
        id: caseSetupContentLeftSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
    }

    ContentRightSide {
        id: caseSetupContentRightSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
        buttonPrimary {
            text: qsTr("NEXT")
            visible: true
            style: ButtonRectanglePrimary.ButtonWithHelp
            help.onClicked: {
                helpPopup.state = "fre"
                helpPopup.open()
            }
        }
    }

    states: [
        State {
            name: "intro_1"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                text: qsTr("MATERIAL CASE SET UP")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("The material case is contained in Box 1.") + "\n\n" +
                      qsTr("This package contains the material case and guide tubes.") + "\n\n" +
                      qsTr("Lift on the rear of the latch to release the lid and access the guide tubes.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.animatedImage
                source: "qrc:/img/case_intro_1.gif"
                visible: true
            }
        },
        State {
            name: "intro_2"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                visible: false
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("Set up the Material Case 30-100mm from the right side of the printer.") + "\n\n" +
                      qsTr("Positioning as shown is important to material routing. Failure to follow this guidance may result in print issues.") + "\n\n" +
                      qsTr("Click the help icon for additional info.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.image
                source: "qrc:/img/case_intro_2.png"
                visible: true
            }
        },
        State {
            name: "tube_1_case"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                text: qsTr("CONNECT GUIDE TUBE 1 TO CASE")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("Connect the guide tube for the model material by inserting the tube into the Port 1 gasket.") + "\n\n" +
                      qsTr("Ensure the tube is completely in to prevent issues during material loading.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.image
                source: "qrc:/img/case_tube_1_case.png"
                visible: true
            }
        },
        State {
            name: "tube_1_printer"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                text: qsTr("CONNECT GUIDE TUBE 1 TO PRINTER")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("This guide tube will connect to Port 1 on the printer side.") + "\n\n" +
                      qsTr("When viewing from the rear, Port 1 is on the right side.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.image
                source: "qrc:/img/case_tube_1_printer.png"
                visible: true
            }
        },
        State {
            name: "tube_2"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                text: qsTr("CONNECT GUIDE TUBE 2 TO MATERIAL CASE + PRINTER")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("Follow the same procedure to connect the tube to Port 2 on the material case and printer.") + "\n\n" +
                      qsTr("When viewing from rear, Port 2 is on the left side.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.image
                source: "qrc:/img/case_tube_2.png"
                visible: true
            }
        },
        State {
            name: "remove_divider"

            PropertyChanges {
                target: caseSetupContentRightSide.textHeader
                text: qsTr("REMOVE DIVIDER")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentRightSide.textBody
                text: qsTr("This component provides instructions on where to locate your spools when loading.")
                visible: true
            }

            PropertyChanges {
                target: caseSetupContentLeftSide.image
                source: "qrc:/img/case_divider.png"
                visible: true
            }
        }
    ]
}
