import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property alias topBar: topBar
    property var currentItem: mainMenu
    property var activeDrawer
    property bool authRequest: bot.isAuthRequestPending
    property bool skipAuthentication: false
    property bool isAuthenticated: false

    Timer {
        id: authTimeOut
        onTriggered: {
            if(authRequest) {
                bot.respondAuthRequest("timedout")
                skipAuthentication = false
                isAuthenticated = false
                authenticatePrinterPopup.close()
                authTimeOut.stop()
            }
            else {
                isAuthenticated = false
                authenticatePrinterPopup.close()
                authTimeOut.stop()
            }
        }
    }

    onSkipAuthenticationChanged: {
        authenticate_rectangle.color = "#ffffff"
        authenticate_text.color = "#000000"
    }

    onAuthRequestChanged: {
        if(authRequest) {
            isAuthenticated = false
            authenticatePrinterPopup.open()
            authTimeOut.interval = 300000
            authTimeOut.start()
        }
        else {
            if(isAuthenticated) {
                authTimeOut.interval = 3000
                authTimeOut.start()
            }
        }
    }

    function setDrawerState(state) {
        topBar.imageDrawerArrow.visible = state
        activeDrawer.interactive = state
        if(state == true) {
            topBar.drawerDownClicked.connect(activeDrawer.open)
        }
        else {
            topBar.drawerDownClicked.disconnect(activeDrawer.open)
        }
    }

    function setCurrentItem(currentItem_) {
        currentItem = currentItem_
    }

    function goBack(){
        if(currentItem.hasAltBack){
            currentItem.altBack()
        }
        else{
            currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
        }
    }

    function disableDrawer()
    {
        topBar.imageDrawerArrow.visible = false
        if(activeDrawer == printPage.printingDrawer
                || activeDrawer == materialPage.materialPageDrawer
                || activeDrawer == printPage.sortingDrawer) {
            activeDrawer.interactive = false
            topBar.drawerDownClicked.disconnect(activeDrawer.open)
        }
    }

    Item{
        id: rootItem
        smooth: false
        rotation: 180
        anchors.fill: parent
        objectName: "morepork_main_qml"
        z: 0

        Rectangle {
            id: rectangle
            color: "#000000"
            smooth: false
            z: -1
            anchors.fill: parent
        }

        Drawer{
            id: backSwipe
            width: rootAppWindow.width
            height: rootAppWindow.height
            edge: rootItem.rotation == 180 ? Qt.RightEdge : Qt.LeftEdge
            dim: false
            opacity: 0
            interactive: mainSwipeView.currentIndex
            onOpened:
            {
                position = 0
                goBack()
                close()
            }
        }

        TopBarForm{
            id: topBar
            z: 1
            width: parent.width
            smooth: false
            backButton.visible: false
            imageDrawerArrow.visible: false

            onBackClicked: {
                goBack()
            }
        }

        SwipeView {
            id: mainSwipeView
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            interactive: false
            transform: Translate {
                x: backSwipe.position * mainSwipeView.width * 1.5
            }
            property alias materialPage: materialPage
            smooth: false

            function swipeToItem(itemToDisplayDefaultIndex) {
                var prevIndex = mainSwipeView.currentIndex
                mainSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
                if(itemToDisplayDefaultIndex === 0) {
                    mainSwipeView.setCurrentIndex(0)
                    topBar.backButton.visible = false
                    if(!printPage.isPrintProcess) {
                        disableDrawer()
                    }
                }
                else {
                    mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem.visible = true
                    setCurrentItem(mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem)
                    mainSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
                    topBar.backButton.visible = true
                }
                mainSwipeView.itemAt(prevIndex).visible = false
            }

            // mainSwipeView.index = 0
            Item {
                smooth: false
                MainMenu {
                    id: mainMenu
                    anchors.fill: parent

                    mainMenuIcon_print.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(1)
                    }

                    mainMenuIcon_extruder.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(2)
                    }

                    mainMenuIcon_settings.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(3)
                    }

                    mainMenuIcon_info.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(4)
                    }

                    mainMenuIcon_material.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(5)
                    }

                    mainMenuIcon_preheat.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(6)
                    }
                }
            }

            // mainSwipeView.index = 1
            Item {
                property alias defaultItem: printPage.defaultItem
                smooth: false
                visible: false
                PrintPage {
                    id: printPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 2
            Item {
                property int defaultIndex: 2
                property alias defaultItem: extruderPage.defaultItem
                smooth: false
                visible: false
                ExtruderPage {
                    id: extruderPage
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 3
            Item {
                property int defaultIndex: 3
                property alias defaultItem: settingsPage.defaultItem
                smooth: false
                visible: false
                SettingsPage {
                    id: settingsPage
                    smooth: false
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 4
            Item {
                property int defaultIndex: 4
                property alias defaultItem: infoPage.defaultItem
                smooth: false
                visible: false
                InfoPage {
                    id: infoPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 5
            Item {
                property int defaultIndex: 5
                property alias defaultItem: materialPage.defaultItem
                smooth: false
                visible: false
                MaterialPage {
                    id: materialPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 6
            Item {
                property int defaultIndex: 6
                property alias defaultItem: preheatPage.defaultItem
                smooth: false
                visible: false
                PreheatPage {
                    id: preheatPage
                    smooth: false
                    anchors.fill: parent
                }
            }
        }

        Popup {
            id: authenticatePrinterPopup
            width: 800
            height: 480
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

            onOpened: {
                authenticate_rectangle.color = "#ffffff"
                authenticate_text.color = "#000000"
            }

            Rectangle {
                id: basePopupItem
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: skipAuthentication ? 225 : 400
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: authImage
                    width: 241
                    height: 240
                    anchors.left: parent.left
                    anchors.leftMargin: 70
                    anchors.top: parent.top
                    anchors.topMargin: 42
                    source: isAuthenticated ? "qrc:/img/auth_success.png" : "qrc:/img/auth_waiting.png"
                    visible: !skipAuthentication
                }

                Item {
                    id: columnLayout
                    x: 345
                    y: 87
                    width: 300
                    height: 150
                    anchors.top: parent.top
                    anchors.topMargin: skipAuthentication ? 35 : 87
                    anchors.right: parent.right
                    anchors.rightMargin: skipAuthentication ? 250 : 60

                    Text {
                        id: authenticate_header_text
                        color: "#cbcbcb"
                        text: isAuthenticated ? "AUTHENTICATION COMPLETE" : skipAuthentication ? "CANCEL AUTHENTICATION" : "AUTHENTICATE"
                        width: skipAuthentication ? 600 : 300
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: skipAuthentication ? 5 : 0
                        wrapMode: Text.WordWrap
                        font.letterSpacing: 5
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: skipAuthentication ? 20 : 24
                    }

                    Text {
                        id: authenticate_description_text1
                        color: "#cbcbcb"
                        text: isAuthenticated ? "" : skipAuthentication ? "Are you sure you want to cancel?" : "Would you like to authenticate"
                        anchors.left: parent.left
                        anchors.leftMargin: skipAuthentication ? 30 : 0
                        anchors.top: parent.top
                        anchors.topMargin: skipAuthentication ? 55 : 65
                        horizontalAlignment: Text.AlignLeft
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        font.letterSpacing: 1
                    }

                    Text {
                        id: authenticate_description_text2
                        color: "#ffffff"
                        text: skipAuthentication ? "" : bot.username
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: 100
                        horizontalAlignment: Text.AlignLeft
                        font.weight: Font.Bold
                        wrapMode: Text.NoWrap
                        font.capitalization: Font.AllUppercase
                        font.family: "Antennae"
                        font.pixelSize: 18
                        font.letterSpacing: 3
                    }

                    Text {
                        id: authenticate_description_text3
                        color: "#cbcbcb"
                        text: isAuthenticated ? "is now authenticated to this printer" : skipAuthentication ? "" : "to this printer?"
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: 135
                        horizontalAlignment: Text.AlignLeft
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        font.letterSpacing: 1
                    }
                }

                Rectangle {
                    id: horizontal_divider
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                    visible: !isAuthenticated
                }

                Rectangle {
                    id: vertical_divider
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: !isAuthenticated
                }

                Item {
                    id: item1
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    visible: !isAuthenticated

                    Rectangle {
                        id: dismiss_rectangle
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: dismiss_text
                            color: "#ffffff"
                            text: skipAuthentication ? "BACK" : "DISMISS"
                            Layout.fillHeight: false
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: false
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: dismiss_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                dismiss_text.color = "#000000"
                                dismiss_rectangle.color = "#ffffff"
                                authenticate_text.color = "#ffffff"
                                authenticate_rectangle.color = "#00000000"
                            }
                            onReleased: {
                                dismiss_text.color = "#ffffff"
                                dismiss_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                if(skipAuthentication == false) {
                                    skipAuthentication = true
                                }
                                else if(skipAuthentication == true) {
                                    skipAuthentication = false
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: authenticate_rectangle
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: authenticate_text
                            color: "#ffffff"
                            text: skipAuthentication ? "CONTINUE" : "AUTHENTICATE"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: authenticate_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                authenticate_text.color = "#000000"
                                authenticate_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                authenticate_text.color = "#ffffff"
                                authenticate_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                if(skipAuthentication == false) {
                                    bot.respondAuthRequest("accepted")
                                    isAuthenticated = true
                                }
                                else if(skipAuthentication == true) {
                                    bot.respondAuthRequest("rejected")
                                    isAuthenticated = false
                                    skipAuthentication = false
                                    authenticatePrinterPopup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
