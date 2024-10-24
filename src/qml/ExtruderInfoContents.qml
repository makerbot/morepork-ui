import QtQuick 2.10

ExtruderInfoContentsForm {
    onExtPresentAndVisibleChanged: {
        if (extPresentAndVisible) {
            bot.getToolStats(toolIdx);
        }
    }
}

