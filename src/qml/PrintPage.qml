import QtQuick 2.4

PrintPageForm {
    printingDrawer.mouseArea_topDrawerUp.onClicked: {
        printingDrawer.close()
    }

    printingDrawer.button_cancelPrint.onClicked: {
        bot.cancel()
        printingDrawer.close()
    }

    printingDrawer.button_pausePrint.onClicked: {
        bot.pausePrint()
        printingDrawer.close()
    }
}
