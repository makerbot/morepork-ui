import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias printingDrawer: printingDrawer
    property alias mouseAreaTopDrawerUp: printingDrawer.mouseAreaTopDrawerUp
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint

    PrintingDrawer {
        id: printingDrawer
    }

    PrintIconForm{
        x: 8
        y: 40
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8
    }
}
