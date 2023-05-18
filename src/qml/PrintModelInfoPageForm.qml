import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0
import ProcessTypeEnum 1.0

Item {
    anchors.fill: parent.fill
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    property alias startPrintButtonVisible: startPrintButtonRow.visible
    property alias customModelSource: model_image1.customSource

    RowLayout {
        id: print_page_row_layout
        anchors.fill: parent.fill
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 15
        anchors.bottomMargin: 15
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
            width: 365
            Layout.preferredWidth: 365
            visible: true
            spacing: 25

            ColumnLayout {
                id: details_column
                spacing: 8
                Layout.maximumWidth: parent.width

                TextBody {
                    id: printName
                    text: file_name
                    width: details_item.width
                    Layout.preferredWidth: details_item.width
                    elide: Text.ElideRight
                    font.weight: Font.Bold

                    // local override of wrapping until wider testing can be done
                    wrapMode: Text.Wrap
                }

                TextSubheader {
                    id: printTime
                    text: qsTr("PRINT TIME | %1").arg(print_time)
                    font.weight: Font.Light
                    opacity: 0.7
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

            RowLayout {
                id: startPrintButtonRow
                width: children.width
                height: startPrintButton.height
                spacing: 10
                visible: false

                ButtonRectanglePrimary {
                    id: startPrintButton
                    width: 300
                    Layout.preferredWidth: 300
                    text: qsTr("START")
                    onClicked: {
                        if(!startPrintCheck()) {
                            startPrintErrorsPopup.open()
                        } else {
                            confirm_build_plate_popup.open()
                        }
                    }
                }

                ButtonOptions {
                    id: moreOptionsButton
                    Layout.preferredWidth: width
                    visible: !inFreStep
                    enabled: !(startPrintSource == PrintPage.FromPrintQueue)
                    onClicked: {
                        startPrintButton.enabled = false
                        was_pressed = true
                        optionsMenu.open()
                    }
                }
            }
            // The File Options Pop up for this page
            FileOptionsPopupMenu {
                id: optionsMenu
                width: details_item.width
                y: startPrintButtonRow.y-height-8

                onClosed: {
                    startPrintButton.enabled = true
                    moreOptionsButton.was_pressed = false
                }
            }
        }

    }
}
