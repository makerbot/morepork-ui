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

    Component.onCompleted: {
       topBar.backClicked.connect(backClicked_)
    }

    function backClicked_() {
        printDeleteSwipeView.setCurrentIndex(0)
    }
}
