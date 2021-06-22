import QtQuick 2.10

FailurePrintFeedbackForm {
    property var defects: ({})

    function updateFeedbackDict(key, selected) {
        defects[key] = selected
    }
}
