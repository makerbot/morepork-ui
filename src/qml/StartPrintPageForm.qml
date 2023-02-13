import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0

Item {
    width: 800
    height: 440
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
                    width: 800
                    height: 420
                    smooth: false
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20

                    ImageWithFeedback {
                        id: model_image1
                        width: 212
                        height: 300
                        anchors.left: parent.left
                        anchors.leftMargin: 100
                        asynchronous: true
                        anchors.verticalCenter: parent.verticalCenter
                        loadingSpinnerSize: 48
                    }

                    Item {
                        id: detailsItem
                        width: 400
                        height: 375
                        antialiasing: false
                        smooth: false
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 20
                        anchors.left: parent.left
                        anchors.leftMargin: 400

                        Text {
                            id: printName
                            width: 330
                            text: file_name
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            smooth: false
                            antialiasing: false
                            font.letterSpacing: 3
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.pixelSize: 21
                            lineHeight: 1.1
                            color: "#cbcbcb"

                            Image {
                                id: infoIcon
                                width: sourceSize.width
                                height: sourceSize.height
                                anchors.left: parent.right
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                antialiasing: false
                                smooth: false
                                source: "qrc:/img/info_icon_small.png"

                                LoggingMouseArea {
                                    logText: "start_print_swipe_view [[info_icon_sml]]"
                                    width: 80
                                    height: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: printSwipeView.swipeToItem(PrintPage.FileInfoPage)
                                }
                            }
                        }

                        RowLayout {
                            id: printTimeRowLayout
                            anchors.top: printName.bottom
                            anchors.topMargin: 12
                            antialiasing: false
                            smooth: false
                            spacing: 10

                            Text {
                                id: printTimeLabel
                                text: "PRINT TIME"
                                smooth: false
                                antialiasing: false
                                font.letterSpacing: 3
                                font.family: defaultFont.name
                                font.weight: Font.Light
                                font.pixelSize: 18
                                color: "#ffffff"
                            }

                            Rectangle {
                                id: dividerRectangle
                                width: 1
                                height: 18
                                color: "#ffffff"
                                antialiasing: false
                                smooth: false
                            }

                            Text {
                                id: printTime
                                text: print_time
                                smooth: false
                                antialiasing: false
                                font.letterSpacing: 3
                                font.family: defaultFont.name
                                font.weight: Font.Light
                                font.pixelSize: 18
                                color: "#ffffff"
                            }
                        }

                        Text {
                            id: readyByLabel
                            text: "READY BY : " + readyByTime
                            anchors.top: printTimeRowLayout.bottom
                            anchors.topMargin: 10
                            smooth: false
                            antialiasing: false
                            font.letterSpacing: 3
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.pixelSize: 18
                            color: "#ffffff"
                            visible: false
                        }

                        StartPrintMaterialViewItem {
                            id: materialBay1
                            anchors.top: printTimeRowLayout.bottom
                            anchors.topMargin: 28
                            filamentBayID: 1
                            materialRequired: modelMaterialRequired
                        }

                        StartPrintMaterialViewItem {
                            id: materialBay2
                            anchors.top: materialBay1.bottom
                            anchors.topMargin: 12
                            filamentBayID: 2
                            materialRequired: supportMaterialRequired
                            visible: support_extruder_used
                        }

                        RoundedButton {
                            id: startPrintButton
                            anchors.top: materialBay2.bottom
                            anchors.topMargin: 28
                            buttonWidth: inFreStep ? 300 : 210
                            buttonHeight: 50
                            label: inFreStep ? qsTr("START TEST PRINT") : qsTr("START")
                            button_mouseArea.onClicked: {
                                if(startPrintSource == PrintPage.FromLocal) {
                                    if(startPrintCheck()){
                                        startPrint()
                                    }
                                    else {
                                        startPrintErrorsPopup.open()
                                    }
                                } else if(startPrintSource == PrintPage.FromPrintQueue) {
                                    print_queue.startQueuedPrint(print_url_prefix,
                                                                 print_job_id,
                                                                 print_token)
                                    printFromQueueState = PrintPage.WaitingToStartPrint
                                }
                            }
                        }

                        RoundedButton {
                            id: moreOptionsButton
                            buttonWidth: 75
                            buttonHeight: 50
                            label: "···"
                            label_size: 30
                            visible: !inFreStep
                            disable_button: startPrintSource == PrintPage.FromPrintQueue
                            anchors.top: materialBay2.bottom
                            anchors.topMargin: 28
                            anchors.left: startPrintButton.right
                            anchors.leftMargin: 15
                            button_text.anchors.verticalCenterOffset: 10
                            button_mouseArea.onClicked: {
                                optionsMenu.open()
                            }

                            FileOptionsPopupMenu {
                                id: optionsMenu
                                x: -75
                                y: -170
                            }
                        }
                    }
                }


        // StartPrintPage.PrintFileDetails
        Item {
            id: startPrintPage2
            anchors.fill: parent.fill
            smooth: false

            /*ImageWithFeedback {
                id: model_image2
                width: 212
                height: 300
                asynchronous: true
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter
                loadingSpinnerSize: 48
            }*/

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
                    id: filename_item
                    labelText: qsTr("FILENAME")
                    dataText: file_name
                }

                InfoItem {
                    id: print_mode_info
                    labelText: qsTr("PRINT MODE")
                    dataText: qsTr("BALANCED")

                }

                InfoItem {
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
                }

                InfoItem {
                    id: model_info
                    labelText: qsTr("MODEL")
                    dataText: qsTr("%1 %2").arg(model_mass).arg(print_model_material_name)
                }

                InfoItem {
                    id: support_item
                    labelText: qsTr("SUPPORT")
                    dataText: qsTr("%1 %2").arg(support_mass).arg(print_support_material_name)

                }
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
