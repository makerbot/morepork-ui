import QtQuick 2.4

PrintPageForm {
    buttonUsbStorage.buttonText.text: qsTr("USB Storage") + cpUiTr.emptyStr
    buttonInternalStorage.buttonText.text: qsTr("Internal Storage") + cpUiTr.emptyStr
    startPrintLabel.text: qsTr("Start Print") + cpUiTr.emptyStr

    printingDrawer.buttonCancelPrint.onClicked: {
        bot.cancel()
        printingDrawer.close()
    }

    printingDrawer.buttonPausePrint.onClicked: {
        bot.pausePrint()
        printingDrawer.close()
    }

    printingDrawer.buttonChangeFilament.onClicked: {

    }

    printingDrawer.buttonClose.onClicked: {
        printingDrawer.close()
    }
}
