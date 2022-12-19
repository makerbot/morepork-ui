import QtQuick 2.12

Image {
    id: thumbnail_image
    asynchronous: true
    smooth: false
    sourceSize.width: width
    sourceSize.height: height
    source: {
        if(startPrintSource == PrintPage.FromPrintQueue) {
            "image://async/" + print_url_prefix + "+" +
                                     print_job_id + "+" +
                                     print_token
        } else if(startPrintSource == PrintPage.FromLocal) {
            "image://thumbnail/" + fileName
        } else {
            emptyString
        }
    }

    Rectangle {
        height: 72
        width: 72
        color: "#1c1c1c"
        radius: 36
        border.width: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: thumbnail_image.status == Image.Loading
    }
}
