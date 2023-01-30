import QtQuick 2.10
import MachineTypeEnum 1.0

Item {
    id: matIcon
    width: 100
    height: 100
    smooth: false

    Rectangle {
        color: "#000000"
        anchors.fill: parent
    }

    Image {
        id: error_image
        source: "qrc:/img/extruder_material_error.png"
        width: sourceSize.width
        height: sourceSize.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        id: material_status_icon
        anchors.fill: parent

        Rectangle {
            id: outer_ring
            width: 87.5
            height: 87.5
            radius: width/2
            color: "#00000000"
            border.color: "#ffffff"
            border.width: 3
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
             id: inner_ring
             width: 37.5
             height: 37.5
             radius: width/2
             color: "#00000000"
             border.color: "#ffffff"
             border.width: 3
             anchors.horizontalCenter: parent.horizontalCenter
             anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: filament_extension
            width: 3
            height: outer_ring.radius
            color: "#ffffff"
            anchors.top: outer_ring.top
            anchors.left: outer_ring.left
        }

        Rectangle {
            id: material_amount_ring
            anchors.fill: outer_ring
            color: "#00000000"
            antialiasing: false
            smooth: false
            property int fillPercent: filamentPercent
            property string fillColor: filamentColor

            onFillPercentChanged: canvas.requestPaint()
            onFillColorChanged: canvas.requestPaint()

            Canvas {
                id: canvas
                smooth: true
                antialiasing: true
                rotation: -90
                anchors.fill: parent
                onPaint: {
                    var context = getContext("2d");
                    context.reset();
                    var centreX = parent.width * 0.5;
                    var centreY = parent.height * 0.5;
                    context.beginPath();
                    //0.06283185 = PI*2/100
                    context.arc(centreX, centreY, parent.width*0.35, 0,
                                parent.fillPercent*0.06283185, false);
                    context.lineWidth = 10;
                    context.lineCap = "round";
                    context.strokeStyle = parent.fillColor;
                    context.stroke()
                }
            }
        }
    }
    Image {
        id: material_image_error
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: sourceSize.width
        height: sourceSize.height
        source: "qrc:/img/error_image_overlay.png"
    }
    states: [
        State {
            name: "not_loaded_no_rfid"
            when: !spoolPresent && !extruderFilamentPresent

            PropertyChanges {
                target: error_image
                visible: true
            }

            PropertyChanges {
                target: material_status_icon
                visible: false
            }

            PropertyChanges {
                target: material_amount_ring
                visible: false
            }

            PropertyChanges {
                target: material_image_error
                visible: false
            }
        },
        State {
            name: "rfid_present"
            when: spoolPresent

            PropertyChanges {
                target: error_image
                visible: false
            }

            PropertyChanges {
                target: material_status_icon
                visible: true
            }

            PropertyChanges {
                target: material_amount_ring
                visible: true
            }

            PropertyChanges {
                target: material_image_error
                visible: false
            }
        },
        State {
            name: "loaded_no_rfid"
            when: !spoolPresent && extruderFilamentPresent

            PropertyChanges {
                target: error_image
                visible: false
            }

            PropertyChanges {
                target: material_status_icon
                visible: true
            }

            PropertyChanges {
                target: material_amount_ring
                visible: false
            }

            PropertyChanges {
                target: material_image_error
                visible: false
            }
        }
    ]
}
