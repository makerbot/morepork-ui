import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

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
            //dataElement.Layout.preferredWidth: parent.width
            dataElement.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            dataText: file_name
        }

        InfoItem {
            id: submitted_by_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("SUBMITTED BY")
            dataText: ""
            visible: (startPrintSource == PrintPage.FromPrintQueue)
        }

        InfoItem {
            id: print_time_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("PRINT TIME")
            dataText: print_time.replace("HR"," HOURS").replace("M"," MINUTES")
        }

        InfoItem {
            id: material_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("MATERIAL")
            dataText: qsTr("%1 + %2").arg(print_model_material_name).arg(print_support_material_name)
        }

        InfoItem {
            id: print_mode_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("PRINT MODE")
            dataText: qsTr("BALANCED*")

        }

        InfoItem {
            id: extruder_temp_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("EXTRUDER TEMP.")
            dataText: extruder_temp.replace("+","|")
        }

        InfoItem {
            id: notes_info
            Layout.preferredHeight: dataElement.height
            labelText: qsTr("NOTES")
            dataText: ""
            visible: (startPrintSource == PrintPage.FromPrintQueue)
        }

    }
}
