import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    anchors.fill: parent
    property bool chamberDoorOpen: bot.chamberErrorCode == 48 && !bot.doorErrorDisabled

    onChamberDoorOpenChanged: {
        if(chamberDoorOpen &&
          buildPlateSettingsSwipeView.currentIndex == BuildPlateSettingsPage.RaiseLowerBuildPlatePage) {
            doorOpenRaiseLowerBuildPlatePopup.open()
        }
    }

    Component {
        id: tumblerTextDelegate
        TextHeadline {
            style: TextHeadline.Large
            text: model.modelData
            color: Tumbler.tumbler.currentItem.text == model.modelData ?
                       "#ffffff" : "#666666"
        }
    }

    RowLayout {
        spacing: 80
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        ColumnLayout {
            spacing: 48

            TextBody {
                id: distanceText
                style: TextBody.ExtraLarge
                text: qsTr("DISTANCE (mm)")
            }

            Tumbler {
                id: distanceTumbler
                visibleItemCount: 3
                wrap: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: 200
                Layout.preferredWidth: 100
                model: [1,2,3,5,10,15,25,50,100]
                delegate: tumblerTextDelegate
            }
        }

        ColumnLayout {
            spacing: 48

            TextBody {
                id: speedText
                style: TextBody.ExtraLarge
                text: qsTr("SPEED (mm/s)")
            }

            Tumbler {
                id: speedTumbler
                visibleItemCount: 3
                wrap: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: 200
                Layout.preferredWidth: 100
                model: [5,10,15,20]
                delegate: tumblerTextDelegate
            }
        }

        ColumnLayout {
            spacing: 48

            ButtonRectanglePrimary {
                id: moveUpButton
                Layout.preferredWidth: 135
                text: qsTr("UP")

                enabled: !isProcessRunning() && !chamberDoorOpen

                onClicked: {
                    bot.moveBuildPlate(-distanceTumbler.model[distanceTumbler.currentIndex],
                                       speedTumbler.model[speedTumbler.currentIndex])
                }
            }

            ButtonRectanglePrimary {
                id: moveDownButton
                Layout.preferredWidth: 135
                text: qsTr("DOWN")

                enabled: !isProcessRunning() && !chamberDoorOpen

                onClicked: {
                    bot.moveBuildPlate(distanceTumbler.model[distanceTumbler.currentIndex],
                                       speedTumbler.model[speedTumbler.currentIndex])
                }
            }
        }
    }
}
