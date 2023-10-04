import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    anchors.fill: parent
    property int customTime: {
        if(bot.machineType == MachineType.Magma) {
            16
        } else {
            24
        }
    }

    Component {
        id: tumblerTextDelegate
        TextHeadline {
            text: model.modelData
            font.pixelSize: Tumbler.tumbler.currentItem.text == model.modelData ?
                                48 : 32
            color: Tumbler.tumbler.currentItem.text == model.modelData ?
                       "#ffffff" : "#666666"
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: 50
                }
            }
        }
    }

    RowLayout {
        spacing: 80
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        TextBody {
            id: temperatureText
            style: TextBody.ExtraLarge
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: qsTr("Temperature (°C)")
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 0

            Rectangle {
                id: tumblerTop
                Layout.preferredWidth: 20
                Layout.preferredHeight: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: "#666666"
            }

            VerticalTumbler {
                id: tempTumbler
                width: 90
                visibleItemCount: 3
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                upperOffset: 36
                lowerOffset: 30
                Layout.preferredHeight: 200
                Layout.preferredWidth: 100
                // Tumbler does not look good with only
                // three values so put in doubles
                model: [50,60,70,50,60,70]
                delegate: tumblerTextDelegate
            }

            Rectangle {
                id: tumblerBottom
                Layout.preferredWidth: 20
                Layout.preferredHeight: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: "#666666"
            }
        }

        ButtonRectanglePrimary {
            id: startButton
            Layout.preferredWidth: 135
            text: qsTr("START")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                bot.startDrying(parseInt(tempTumbler.model[tempTumbler.currentIndex], 10), customTime)
            }
        }
    }

}

