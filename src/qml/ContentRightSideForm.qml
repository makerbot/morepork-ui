import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    width: 400
    height: 408
    property alias textHeader: textHeader
    property alias numberedSteps: numberedSteps
    property alias textBody: textBody
    property alias buttonPrimary: buttonPrimary
    property alias buttonSecondary1: buttonSecondary1
    property alias buttonSecondary2: buttonSecondary2

    ColumnLayout {
        width: 360
        anchors.verticalCenter: parent.verticalCenter
        spacing: 32

        ColumnLayout {
            spacing: 24

            TextHeadline {
                id: textHeader
                style: TextHeadline.Base
                text: "standard header"
            }

            NumberedSteps {
                id: numberedSteps
                visible: false
                steps: ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do"]
            }

            TextBody {
                id: textBody
                style: TextBody.Base
                font.weight: Font.Normal
                Layout.fillWidth: true
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id purus feugiat sed nisi, quam. Orci, in eu interdum erat purus, proin."
            }
        }

        ColumnLayout {
            spacing: 24

            ButtonRectanglePrimary {
                id: buttonPrimary
                text: "label"
            }

            ButtonRectangleSecondary {
                id: buttonSecondary1
                text: "label"
            }

            ButtonRectangleSecondary {
                id: buttonSecondary2
                text: "label"
            }
        }
    }
}
