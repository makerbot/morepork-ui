import QtQuick 2.10

ExtruderInfoContentsForm {
    onExtruderPresentChanged: {
        if (extruderPresent) {
            bot.getToolStats(toolIdx);
        }
    }
}

