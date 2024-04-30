import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    anchors.fill: parent
    property bool chamberDoorOpen: bot.chamberErrorCode == 48 && !bot.doorErrorDisabled

    function disableArrows() {
        directionArrows.upEnabled = false
        directionArrows.downEnabled = false
    }

    onChamberDoorOpenChanged: {
        if(chamberDoorOpen &&
          buildPlateSettingsSwipeView.currentIndex == BuildPlateSettingsPage.RaiseLowerBuildPlatePage) {
            doorOpenMoveBuildPlatePopup.open()
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

        ColumnLayout {
            spacing: 45

            TextBody {
                id: distanceText
                style: TextBody.ExtraLarge
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: qsTr("DISTANCE (mm)")
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 0

                Rectangle {
                    id: distanceTop
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: "#666666"
                }

                VerticalTumbler {
                    id: distanceTumbler
                    width: 90
                    visibleItemCount: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    upperOffset: 36
                    lowerOffset: 30
                    Layout.preferredHeight: 200
                    Layout.preferredWidth: 100
                    model: [1,2,3,5,10,15,25,50,100]
                    delegate: tumblerTextDelegate
                }

                Rectangle {
                    id: distanceBottom
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: "#666666"
                }
            }
        }

        ColumnLayout {
            spacing: 48

            TextBody {
                id: directionText
                style: TextBody.ExtraLarge
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: qsTr("DIRECTION")
            }

            DirectionArrowsComponent {
                id: directionArrows
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: 200
                Layout.preferredWidth: directionText.width

            }
        }

        ButtonRectanglePrimary {
            id: moveUpButton
            Layout.preferredWidth: 135
            text: qsTr("MOVE")

            // Move button top margin due to
            // headings and spacing from column layout
            Layout.topMargin: 74
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            onClicked: {
                var value = (directionArrows.direction()*
                             distanceTumbler.model[distanceTumbler.currentIndex])
                if(value === 0) {
                    customMoveAttentionPopup.open()
                    return
                }
                bot.moveBuildPlate(value, 20)
            }
            enabled: !isProcessRunning() && !chamberDoorOpen
        }
    }

    CustomPopup {
        id: customMoveAttentionPopup
        popupName: "CustomMoveAttention"
        popupHeight:customMoveColumnLayout.height+135
        showOneButton: true
        fullButtonText: qsTr("OK")
        fullButton.onClicked: {
            customMoveAttentionPopup.close()
        }

        ColumnLayout {
            id: customMoveColumnLayout
            height: children.height
            anchors.top: customMoveAttentionPopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: attentionImage
                width: sourceSize.width -10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_error_small.png"
            }

            TextHeadline {
                id: attentionHeadline
                text: qsTr("ATTENTION")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: attentionText
                text: qsTr("Select a distance and direction to move the build platform.")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
