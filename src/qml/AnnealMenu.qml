import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

AnnealMenuForm {
    annealPrintButton.onClicked: {
        annealSwipeView.swipeToItem(AnnealMenu.AnnealPrint)
    }

    annealMaterialButton.onClicked: {
        annealSwipeView.swipeToItem(AnnealMenu.AnnealMaterial)
    }
}

