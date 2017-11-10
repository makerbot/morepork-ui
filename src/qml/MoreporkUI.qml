import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property var currentItem: mainLoader
    property bool isForward: true

    function setCurrentItem(currentItem_)
    {
        currentItem = currentItem_
    }

    Item{
        id: rootItem
        rotation: 180
        anchors.fill: parent
        objectName: "morepork_main_qml"
        z: 0

        Rectangle {
            id: rectangle
            color: "#000000"
            z: -1
            anchors.fill: parent
        }

        TopBarForm{
            id: topBar
            z: 1
            width: parent.width
            backButton.visible: true
            imageDrawerArrow.visible: false

            onBackClicked: {
                if(activeElement == "swipe")
                {
                    currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
                }
                else
                {
                    isForward = false
                    mainLoader.source = "MainMenu.qml"
                }
            }
        }

        Loader{
            id: mainLoader
            focus: true
            //asynchronous: true
            source: "MainMenu.qml"
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            onLoaded:
            {
                loaderAnimation.running = true
                isForward = true
            }

            NumberAnimation {
                id: loaderAnimation
                target: mainLoader.item
                property: "x"
                from: rootAppWindow.width
                to: 0
                duration: 300
                easing.type: Easing.InOutExpo
            }
            states: [
                State {
                    name: "backward"; when: !isForward
                    PropertyChanges {
                        target: loaderAnimation
                        from: -rootAppWindow.width
                        to: 0
                    }
                }
            ]
        }

        Connections{
            target: mainLoader.item
            ignoreUnknownSignals: true
            onOpenPrintPage: {mainLoader.source = "PrintPage.qml"}
            onOpenExtruderPage: {mainLoader.source = "ExtruderPage.qml"}
            onOpenSettingsPage: {mainLoader.source = "SettingsPage.qml"}
            onOpenInfoPage: {mainLoader.source = "InfoPage.qml"}
            onOpenMaterialPage: {mainLoader.source = "MaterialPage.qml"}
            onOpenPreheatPage: {mainLoader.source = "PreheatPage.qml"}
        }
    }
}
