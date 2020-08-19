import QtQuick 2.10

PrintFeedbackComponentForm {
    property var defects: ({})

    function updateFeedbackDict(key, selected) {
        defects[key] = selected
    }
}
