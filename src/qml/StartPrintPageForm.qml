import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0

Item {
    width: 800
    height: 408
    smooth: false

    property alias startPrintSwipeView: startPrintSwipeView

    enum SwipeIndex {
        BasePage,
        PrintFileDetails
    }

    SwipeView {
        id: startPrintSwipeView
        smooth: false
        currentIndex: StartPrintPage.BasePage
        anchors.fill: parent
        visible: true

        // StartPrintPage.BasePage
        Item {
            id: startPrintPage1
            anchors.fill: parent.fill
            anchors.bottomMargin: 20

            RowLayout {
                spacing: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.leftMargin: 40

                Item {
                    width: 330
                    height: children.height
                    Layout.alignment: Qt.AlignVCenter

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

                Item {
                    id: detailsItem
                    width: 365
                    height: 350
                    Layout.alignment: Qt.AlignVCenter


                    TextBody {
                        id: printName
                        text: file_name
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.weight: Font.Bold
                    }

                    RowLayout {
                        id: printTimeRowLayout
                        anchors.top: printName.bottom
                        anchors.topMargin: 8
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

                    StartPrintMaterialViewItem {
                        id: materialBay1
                        anchors.top: printTimeRowLayout.bottom
                        anchors.topMargin: 20
                        filamentBayID: 1
                        materialRequired: modelMaterialRequired
                    }

                    StartPrintMaterialViewItem {
                        id: materialBay2
                        anchors.top: materialBay1.bottom
                        anchors.topMargin: 15
                        filamentBayID: 2
                        materialRequired: supportMaterialRequired
                        visible: support_extruder_used
                    }

                    ButtonRectanglePrimary {
                        id: startPrintButton
                        anchors.top: materialBay2.bottom
                        anchors.topMargin: 20
                        width: 300
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
                        visible: !inFreStep
                        enabled: !(startPrintSource == PrintPage.FromPrintQueue)
                        anchors.top: materialBay2.bottom
                        anchors.topMargin: 20
                        anchors.left: startPrintButton.right
                        anchors.leftMargin: 10
                        onClicked: {
                            startPrintButton.enabled = false
                            was_pressed = true
                            optionsMenu.open()
                        }


                    }
                    FileOptionsPopupMenu {
                        id: optionsMenu
                        y: moreOptionsButton.y -110

                        onClosed: {
                            startPrintButton.enabled = true
                            moreOptionsButton.was_pressed = false
                        }
                    }


                }
            }
        }


        // StartPrintPage.PrintFileDetails
        Item {
            id: startPrintPage2
            anchors.fill: parent.fill
            smooth: false

            ColumnLayout {
                id: columnLayout
                width: parent.width
                smooth: false
                spacing: 40
                //anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 60
                anchors.left: parent.left
                anchors.leftMargin: 60
                anchors.horizontalCenter: parent.horizontalCenter

                InfoItem {
                    id: filename_info
                    labelText: qsTr("FILENAME")
                    dataText: file_name
                }

                InfoItem {
                    id: submitted_by_info
                    labelText: qsTr("SUBMITTED BY")
                    dataText: ""
                }

                InfoItem {
                    id: print_time_info
                    labelText: qsTr("PRINT TIME")
                    dataText: print_time.replace("HR"," HOURS").replace("M"," MINUTES")
                }

                InfoItem {
                    id: material_info
                    labelText: qsTr("MATERIAL")
                    dataText: qsTr("%1 + %2").arg(print_model_material_name).arg(print_support_material_name)
                }

                InfoItem {
                    id: print_mode_info
                    labelText: qsTr("PRINT MODE")
                    dataText: qsTr("BALANCED*")

                }

                InfoItem {
                    id: extruder_temp_info
                    labelText: qsTr("EXTRUDER TEMP")
                    dataText: extruder_temp.replace("+","|")
                }

                InfoItem {
                    id: notes_info
                    labelText: qsTr("NOTES")
                    dataText: qsTr("BALANCED MODE WITH %1% INFILL").arg(infill_density)
                }

                /*InfoItem {
                    id: infill_info
                    labelText: qsTr("INFILL")
                    dataText: qsTr("99.99%")

                }

                InfoItem {
                    id: layer_height_info
                    labelText: qsTr("LAYER HEIGHT")
                    dataText: layer_height_mm

                }

                InfoItem {
                    id: shells_info
                    labelText: qsTr("SHELLS")
                    dataText: qsTr("2")
                }*/

                /*InfoItem {
                    id: model_info
                    labelText: qsTr("MODEL")
                    dataText: qsTr("%1 %2").arg(model_mass).arg(print_model_material_name)
                }

                InfoItem {
                    id: support_item
                    labelText: qsTr("SUPPORT")
                    dataText: qsTr("%1 %2").arg(support_mass).arg(print_support_material_name)

                }*/
            }
        }
    }

    PageIndicator {
        id: indicator
        smooth: false
        visible: startPrintSwipeView.visible
        count: startPrintSwipeView.count
        currentIndex: startPrintSwipeView.currentIndex
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle {
            implicitWidth: 12
            implicitHeight: 12

            radius: width / 2
            border.width: 1
            border.color: "#ffffff"
            color: index === indicator.currentIndex ? "#ffffff" : "#00000000"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
