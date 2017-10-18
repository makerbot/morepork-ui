import QtQuick 2.4

PrintPageForm {
    printingDrawer.mouseAreaTopDrawerUp.onClicked: {
        printingDrawer.close()
    }

    printingDrawer.buttonCancelPrint.onClicked: {
        bot.cancel()
        printingDrawer.close()
    }

    printingDrawer.buttonPausePrint.onClicked: {
        bot.pausePrint()
        printingDrawer.close()
    }
}
