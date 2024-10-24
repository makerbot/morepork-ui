import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {

    // Select Language before FRE
    ColumnLayout {
        id: chooseLanguagePage
        spacing: 20

        Item {
            height: 40
            width: 720
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter

            TextSubheader {
                id: titleText
                text: qsTr("CHOOSE LANGUAGE")
                style: TextSubheader.Bold
                width: parent.width
            }
        }

        ButtonRectanglePrimary {
            id: nextButton
            text: qsTr("NEXT")
            width: 720
            Layout.preferredWidth: width
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                fre.gotoNextStep(currentFreStep)
            }
        }

        Item {
            id: changeLanguageItem
            width: 800
            height: 340
            Layout.preferredHeight: height

            LanguageSelector {
                id: fre_language_selection
                clip: true
            }
        }
    }



}
