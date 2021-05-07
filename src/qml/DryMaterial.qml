import QtQuick 2.10

DryMaterialForm {

    left_button.onClicked: {
        buildPlateClearPopup.close()
        bot.drySpool()
    }
}
