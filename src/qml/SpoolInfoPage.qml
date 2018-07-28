import QtQuick 2.7

SpoolInfoPageForm {
    function init() {
        if (initialized) { return; }

        spoolAInfo.init();
        spoolBInfo.init();
        initialized = true;

        console.log(spoolAInfo.width, spoolAInfo.height);
    }
}

