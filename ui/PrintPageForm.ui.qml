import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    property alias printDrawer: printDrawer
    property alias mouseArea_topDrawerUp: printDrawer.mouseArea_topDrawerUp
    property alias button_cancelPrint: printDrawer.button_cancelPrint
    property alias button_pausePrint: printDrawer.button_pausePrint

    PrintDrawer {
        id: printDrawer
    }
}
