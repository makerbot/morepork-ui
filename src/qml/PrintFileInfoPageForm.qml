import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    anchors.fill: parent.fill
    property alias file_name: file_name
    property alias print_time: print_time
    property alias print_material: print_material
    property alias uses_support: uses_support
    property alias print_page: print_page


    ColumnLayout {
        id: layout
        width: parent.width
        smooth: false
        spacing: 40
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        /*width: 600
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 65
        anchors.top: parent.top
        anchors.topMargin: 50
        smooth: false*/

        InfoItem {
            id: printInfo_fileName
            labelText: qsTr("Filename")
            dataText: print_page.file_name
        }

        InfoItem {
            id: printInfo_timeEstimate
            labelText: qsTr("Print Time Estimate")
            dataText: print_time
        }

        InfoItem {
            id: printInfo_material
            labelText: qsTr("Print Material")
            dataText: print_material
        }

        InfoItem {
            id: printInfo_usesSupport
            labelText: qsTr("Supports")
            dataText: uses_support
            visible: false
        }

        InfoItem {
            id: printInfo_usesRaft
            labelText: qsTr("Rafts")
            dataText: uses_raft
            visible: false
        }

        InfoItem {
            id: printInfo_modelMass
            labelText: qsTr("Model")
            dataText: model_mass
        }

        InfoItem {
            id: printInfo_supportMass
            labelText: qsTr("Support")
            dataText: support_mass
            visible: support_extruder_used
        }

        InfoItem {
            id: printInfo_Shells
            labelText: qsTr("Shells")
            dataText: num_shells
            visible: false
        }

        InfoItem {
            id: printInfo_extruderTemperature
            labelText: qsTr("Extruder Temperature")
            dataText: extruder_temp
        }

        InfoItem {
            id: printInfo_buildplaneTemperature
            labelText: qsTr("Chamber Temp. (Build Plane)")
            dataText: buildplane_temp
            labelElement.font.pixelSize: 16
            labelElement.font.letterSpacing: 2
        }

        InfoItem {
            id: printInfo_slicerName
            labelText: qsTr("Slicer Name")
            dataText: slicer_name
            visible: false
        }
    }
}
