import QtQuick 2.4

PrintPageForm {
    buttonUsbStorage.buttonText.text: qsTr("USB Storage") + cpUiTr.emptyStr
    buttonInternalStorage.buttonText.text: qsTr("Internal Storage") + cpUiTr.emptyStr
    buttonFilePrint.buttonText.text: qsTr("Print") + cpUiTr.emptyStr
    buttonFileInfo.buttonText.text: qsTr("Info") + cpUiTr.emptyStr
    buttonFileDelete.buttonText.text: qsTr("Delete") + cpUiTr.emptyStr

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
