import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0
import ProcessTypeEnum 1.0

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
            id: startPrintModelInfo
            anchors.fill: parent.fill
            anchors.bottomMargin: 20

            PrintModelInfoPage {
                anchors.fill: parent.fill
                startPrintButtonVisible: true
            }
        }

        // StartPrintPage.PrintFileDetails
        Item {
            id: startPrintPage2
            anchors.fill: parent.fill

            PrintFileInfoPage {

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
