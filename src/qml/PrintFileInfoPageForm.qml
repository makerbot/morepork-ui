import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    anchors.fill: parent.fill

    ColumnLayout {
        id: columnLayout
        width: parent.width
        smooth: false
        spacing: 20
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter

        InfoItem {
            id: filename_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("FILENAME")
            dataElement.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            dataText: file_name
        }

        InfoItem {
            id: submitted_by_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("SUBMITTED BY")
            dataText: ""
            // Info not available at the moment TODO: BW-5817
            visible: false // (startPrintSource == PrintPage.FromPrintQueue)
        }

        InfoItem {
            id: print_time_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("PRINT TIME")
            dataText: print_time.replace("HR",qsTr(" HOURS")).replace("M",qsTr(" MINUTES"))
        }

        InfoItem {
            id: material_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("MATERIAL")
            dataText: ("%1 + %2").arg(print_model_material_name).arg(print_support_material_name)
        }

        InfoItem {
            id: print_mode_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("PRINT MODE")
            dataText: qsTr("BALANCED*")
            // Info not available from slice file at the moment
            visible: false

        }

        InfoItem {
            id: extruder_temp_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("EXTRUDER TEMP.")
            dataText: extruder_temp
        }

        InfoItem {
            id: chamber_temp_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("BUILD PLANE TEMP.")
            dataText: buildplane_temp
        }

        InfoItem {
            id: heated_build_platform_temp_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("BUILD PLATFORM TEMP.")
            dataText: buildplatform_temp
            visible: bot.machineType == MachineType.Magma
        }

        InfoItem {
            id: notes_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("NOTES")
            dataText: ""
            // Info not available at the moment TODO: BW-5817
            visible: false // (startPrintSource == PrintPage.FromPrintQueue)
        }

    }
}
