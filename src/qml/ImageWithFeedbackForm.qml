import QtQuick 2.12

Image {
    id: image_with_feedback
    property alias loadingSpinnerSize: spinner.spinnerSize
    property alias customSource : image_with_feedback.source

    asynchronous: true
    smooth: false
    sourceSize.width: width
    sourceSize.height: height
    source: {
        if(startPrintSource == PrintPage.FromPrintQueue) {
            "image://async/" + print_url_prefix + "+" +
                                     print_job_id + "+" +
                                     print_token
        } else if(startPrintSource == PrintPage.FromLocal ||
                  startPrintSource == PrintPage.FromPrintAgain) {
            "image://thumbnail/" + fileName
        } else {
            emptyString
        }
    }

    BusySpinner {
        id: spinner
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spinnerSize: 64
        spinnerActive: image_with_feedback.status == Image.Loading
    }
}
