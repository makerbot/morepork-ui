import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

Item {
    property alias bay1: bay1
    property alias bay2: bay2
    property alias defaultItem: itemFilamentBay
    property alias materialSwipeView: materialSwipeView
    property alias loadUnloadFilamentProcess: loadUnloadFilamentProcess
    property alias cancelLoadUnloadPopup: cancelLoadUnloadPopup
    property alias cancel_mouseArea: cancel_mouseArea
    property alias cancel_rectangle: cancel_rectangle
    property alias continue_mouseArea: continue_mouseArea
    property alias continue_rectangle: continue_rectangle
    property alias materialPageDrawer: materialPageDrawer
    property bool isLoadFilament: false

    smooth: false

    MaterialPageDrawer{
        id: materialPageDrawer
    }

    SwipeView {
        id: materialSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = materialSwipeView.currentIndex
            materialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(materialSwipeView.itemAt(itemToDisplayDefaultIndex))
            materialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            materialSwipeView.itemAt(prevIndex).visible = false
        }

        // materialSwipeView.index = 0
        Item {
            id: itemFilamentBay
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            FilamentBay{
                id: bay1
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 25
                filamentBayID: 1
                //filamentMaterialPercent: bot.filament1Percent
                //filamentMaterialColor: bot.filament1Color
                filamentMaterialPercent: 75 //Temporarily so that
                filamentMaterialColor: 1    //the page doesn't look empty!
                filamentMaterialType: "PLA"
                filamentMaterialColorText: "COLOR"
                filamentMaterialQuantity: "0.0"
            }

            FilamentBay{
                id: bay2
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 225
                filamentBayID: 2
                //filamentMaterialPercent: bot.filament2Percent
                //filamentMaterialColor: bot.filament2Color
                filamentMaterialPercent: 65 //Temporarily so that
                filamentMaterialColor: 5    //the page doesn't look empty!
                filamentMaterialType: "PVA"
                filamentMaterialColorText: "COLOR"
                filamentMaterialQuantity: "0.0"
            }
        }

        // materialSwipeView.index = 1
        Item{
            id: itemLoadUnloadFilament
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: 1
            property bool hasAltBack: true
            visible: true

            function altBack(){
                cancelLoadUnloadPopup.open()
            }
            LoadUnloadFilament{
                id: loadUnloadFilamentProcess
                filamentBaySwitchActive: bayID == 1 ? bot.filamentBayASwitch : bot.filamentBayBSwitch
                onProcessDone: {
                    state = "base state"
                    materialSwipeView.swipeToItem(0)
                    setDrawerState(false)
                    // If load/unload process completes successfully while,
                    // in print process enable print drawer to set UI back,
                    // to printing state.
                    if(printPage.isPrintProcess) {
                        activeDrawer = printPage.printingDrawer
                        setDrawerState(true)
                    }
                }
            }
        }
    }

    Popup{
        id: cancelLoadUnloadPopup
        width: 800
        height: 480
        leftMargin: rootItem.rotation == 0 ? (parent.width - width)/2 : 0
        topMargin: rootItem.rotation == 0 ? (parent.height - height)/2 : 0
        rightMargin: rootItem.rotation == 180 ? (parent.width - width)/2 : 0
        bottomMargin: rootItem.rotation == 180 ? (parent.height - height)/2 : 0
        modal: true
        dim: false
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.5
            anchors.fill: parent
        }
        enter: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }

        Rectangle {
            id: basePopupItem
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 275
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            ColumnLayout {
                id: columnLayout
                width: 484
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: cancel_text
                    color: "#cbcbcb"
                    text: isLoadFilament ? "CANCEL MATERIAL LOADING?" :
                                           "CANCEL MATERIAL UNLOADING?"
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: cancel_description_text
                    color: "#cbcbcb"
                    text: isLoadFilament ? "Are you sure you want to cancel the material loading process?" :
                                           "Are you sure you want to cancel the material unloading process?"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antennae"
                    font.pixelSize: 18
                }
            }

            Rectangle {
                id: horizontal_divider
                width: 720
                height: 1
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Rectangle {
                id: vertical_divider
                x: 360
                y: 178
                width: 1
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RowLayout {
                id: rowLayout
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: cancel_rectangle
                    width: 345
                    height: 65
                    color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -175

                    Text {
                        id: cancel_loading_text
                        color: "#ffffff"
                        text: isLoadFilament ? "CANCEL LOADING" : "CANCEL UNLOADING"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            id: cancel_mouseArea
                            width: 300
                            height: 75
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    id: continue_rectangle
                    width: 350
                    height: 65
                    color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 175
                    Text {
                        id: continue_loading_text
                        color: "#ffffff"
                        text: isLoadFilament ? "CONTINUE LOADING" : "CONTINUE UNLOADING"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            id: continue_mouseArea
                            width: 300
                            height: 75
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
