import QtQuick 2.10

ExtruderInfoContentsForm {
    onExtruderPresentChanged: {
        if (extruderPresent) {
            console.info("extruder present changed");
            bot.getToolStats(toolIdx);
        }
    }
}

