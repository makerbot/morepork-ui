import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0
import ProcessTypeEnum 1.0

Item {
    width: parent.width
    height: parent.height
    anchors.fill: parent.fill

    property alias startPrintButtonVisible: startPrintButtonRow.visible

    RowLayout {
        id: print_page_row_layout
        anchors.bottom: parent.bottom
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.bottomMargin: 15
        anchors.leftMargin: 40
        spacing: 40

        Item {
            id: model_image_item
            width: 330

            ImageWithFeedback {
                id: model_image1
                width: 212
                height: 300
                asynchronous: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                loadingSpinnerSize: 48
            }
        }

        ColumnLayout {
            id: details_item
            Layout.maximumWidth: 365
            visible: true
            spacing: 15

            ColumnLayout {
                id: details_column
                spacing: 8
                Layout.maximumWidth: parent.width

                TextBody {
                    id: printName
                    text: file_name
                    Layout.maximumWidth: details_item.width
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    font.weight: Font.Bold
                }

                RowLayout {
                    id: printTimeRowLayout
                    spacing: 10

                    TextBody {
                        id: printTimeLabel
                        text: "PRINT TIME"
                        font.weight: Font.Light
                    }

                    Rectangle {
                        id: dividerRectangle
                        width: 1
                        height: 18
                        color: "#ffffff"
                        antialiasing: false
                        smooth: false
                    }

                    TextBody {
                        id: printTime
                        text: print_time
                        font.weight: Font.Light
                    }
                }
            }

            StartPrintMaterialViewItem {
                id: materialBay1
                filamentBayID: 1
                materialRequired: modelMaterialRequired
            }

            StartPrintMaterialViewItem {
                id: materialBay2
                filamentBayID: 2
                materialRequired: supportMaterialRequired
                visible: support_extruder_used
            }

            Item {
                id: startPrintButtonRow
                width: children.width
                height: startPrintButton.height
                visible: false

                ButtonRectanglePrimary {
                    id: startPrintButton
                    width: 300
                    Layout.preferredWidth: 300
                    text: inFreStep ? qsTr("START TEST PRINT") : qsTr("START")
                    onClicked: {

                        if(startPrintSource == PrintPage.FromLocal & !startPrintCheck()) {
                            startPrintErrorsPopup.open()
                        } else {
                            confirm_build_plate_popup.open()
                        }
                    }
                }

                ButtonOptions {
                    id: moreOptionsButton
                    anchors.left: startPrintButton.right
                    anchors.leftMargin: 10
                    visible: !inFreStep
                    enabled: !(startPrintSource == PrintPage.FromPrintQueue)
                    onClicked: {
                        startPrintButton.enabled = false
                        was_pressed = true
                        optionsMenu.open()
                    }
                }
            }
        }
    }

    // The File Options Pop up for this page
    FileOptionsPopupMenu {
        id: optionsMenu
        width: details_item.width+15
        x: startPrintButtonRow.x+width+45//410
        y: startPrintButtonRow.y-startPrintButtonRow.height-8//200

        onClosed: {
            startPrintButton.enabled = true
            moreOptionsButton.was_pressed = false
        }
    }
}
