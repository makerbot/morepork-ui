import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 800
    height: 440

    Rectangle {
        id: colorDisplay
        width: 300
        height: 300
        color: Qt.rgba(redSelector.value/255,
                       greenSelector.value/255,
                       blueSelector.value/255,
                       alphaSelector.value/100)
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.verticalCenter: parent.verticalCenter

        Item {
            id: rgbItem
            width: 400
            height: 420
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 25
            anchors.left: colorDisplay.right

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent

                ColorSelectorBox {
                    id: redSelector
                    colorText: "R"
                }

                ColorSelectorBox {
                    id: greenSelector
                    colorText: "G"
                }

                ColorSelectorBox {
                    id: blueSelector
                    colorText: "B"
                }

                ColorSelectorBox {
                    id: alphaSelector
                    colorText: "A"
                    maxColorValue: 100
                }
            }
        }
    }
}
