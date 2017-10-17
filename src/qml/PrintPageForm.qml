import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias printingDrawer: printingDrawer
    property alias mouseArea_topDrawerUp: printingDrawer.mouseArea_topDrawerUp
    property alias button_cancelPrint: printingDrawer.button_cancelPrint
    property alias button_pausePrint: printingDrawer.button_pausePrint

    PrintingDrawer {
        id: printingDrawer
    }
}
