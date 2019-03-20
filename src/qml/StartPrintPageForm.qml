import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 440
    smooth: false

    property alias startPrintSwipeView: startPrintSwipeView

    SwipeView {
        id: startPrintSwipeView
        smooth: false
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        visible: true

        Item {
            id: startPrintPage1
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Image {
                id: model_image1
                smooth: false
                sourceSize.width: 212
                sourceSize.height: 300
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "image://thumbnail/" + fileName
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
                    font.family: "Antenna"
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

                        MouseArea {
                            width: 80
                            height: 80
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: printSwipeView.swipeToItem(3)
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
                        font.family: "Antenna"
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
                        font.family: "Antenna"
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
                    font.family: "Antenna"
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
                    visible: print_support_material != ""
                }

                RoundedButton {
                    anchors.top: materialBay2.bottom
                    anchors.topMargin: 28
                    buttonWidth: inFreStep ? 300 : 210
                    buttonHeight: 50
                    label: inFreStep ? "START TEST PRINT" : "START PRINT"
                    button_mouseArea.onClicked: {
                        if(startPrintCheck()){
                            startPrint()
                        }
                        else {
                            startPrintErrorsPopup.open()
                        }
                    }
                }
            }
        }

        Item {
            id: startPrintPage2
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Image {
                id: model_image2
                smooth: false
                sourceSize.width: 212
                sourceSize.height: 300
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "image://thumbnail/" + fileName
            }

            ColumnLayout {
                id: columnLayout_page1
                width: 400
                height: 225
                smooth: false
                spacing: 3
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: fileName_text1
                    // In a ColumnLayout you must set 'Layout.maximumWidth' not 'width'
                    Layout.maximumWidth: 330
                    text: file_name
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    smooth: false
                    antialiasing: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 21
                    lineHeight: 1.1
                    color: "#cbcbcb"
                }

                Item {
                    id: divider_item1
                    width: 200
                    height: 15
                    smooth: false
                }

                RowLayout {
                    id: rowLayout1
                    width: 100
                    height: 100
                    smooth: false
                    spacing: 30
                    anchors.top: divider_item1.bottom

                    ColumnLayout {
                        id: columnLayout1
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: print_mode_label
                            color: "#cbcbcb"
                            text: "PRINT MODE"
                            font.letterSpacing: 3
                            antialiasing: false
                            font.wordSpacing: 2
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: infill_label
                            color: "#cbcbcb"
                            text: "INFILL"
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: layer_height_label
                            color: "#cbcbcb"
                            text: "LAYER HEIGHT"
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: shells_label
                            color: "#cbcbcb"
                            text: "SHELLS"
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: model_label
                            color: "#cbcbcb"
                            text: "MODEL"
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: support_label
                            color: "#cbcbcb"
                            text: "SUPPORT"
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                    }

                    ColumnLayout {
                        id: columnLayout2
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: print_mode_text
                            color: "#ffffff"
                            text: "BALANCED"
                            font.letterSpacing: 3
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: infill_text
                            color: "#ffffff"
                            text: "99.99%"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: layer_height_text
                            color: "#ffffff"
                            text: layer_height_mm
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: shells_text
                            color: "#ffffff"
                            text: "2"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: model_text
                            color: "#ffffff"
                            text: model_mass + " " + print_model_material
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            font.capitalization: Font.AllUppercase
                        }

                        Text {
                            id: support_text
                            color: "#ffffff"
                            text: support_mass + " " + print_support_material
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            font.capitalization: Font.AllUppercase
                        }
                    }
                }
            }
        }

        Item {
            id: startPrintPage3
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: 960*0.5
                contentHeight: 1460*0.5
                interactive: (flick.contentWidth > 960*0.5 ||
                              flick.contentHeight > 1460*0.5)

                PinchArea {
                    width: Math.max(flick.contentWidth, flick.width)
                    height: Math.max(flick.contentHeight, flick.height)
                    anchors.verticalCenterOffset: -25
                    anchors.verticalCenter: parent.verticalCenter

                    property real initialWidth
                    property real initialHeight
                    onPinchStarted: {
                        initialWidth = flick.contentWidth
                        initialHeight = flick.contentHeight
                    }

                    onPinchUpdated: {
                        // resize content
                        flick.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
                    }

                    onPinchFinished: {
                        // Move its content within bounds.
                        flick.returnToBounds()
                    }

                    Rectangle {
                        width: flick.contentWidth
                        height: flick.contentHeight
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "transparent"
                        Image {
                            anchors.fill: parent
                            sourceSize.width: 960
                            sourceSize.height: 1460
                            source: "image://thumbnail/" + fileName
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    flick.contentWidth = 960*0.5
                                    flick.contentHeight = 1460*0.5
                                }
                            }
                        }
                    }
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
