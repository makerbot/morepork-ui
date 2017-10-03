import QtQuick 2.4

PrintPageForm {
    mouseArea_topDrawerDown.onClicked: {
        printDrawer.open()
    }

    printDrawer.mouseArea_topDrawerUp.onClicked: {
        printDrawer.close()
    }

    printDrawer.button_cancelPrint.onClicked: {
        bot.cancel()
        printDrawer.close()
    }

    printDrawer.button_pausePrint.onClicked: {
        bot.pausePrint()
        printDrawer.close()
    }
}
