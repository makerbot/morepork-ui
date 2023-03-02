import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0
import ProcessTypeEnum 1.0

Item {
    width: 800
    height: 408
    smooth: false

    property alias startPrintSwipeView: startPrintSwipeView

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#000000"
    }

    enum SwipeIndex {
        BasePage,
        PrintFileDetails
    }

    SwipeView {
        id: startPrintSwipeView
        smooth: false
        currentIndex: StartPrintPage.BasePage
        anchors.fill: parent
        visible: true

        // StartPrintPage.BasePage
        Item {
            id: startPrintModelInfo
            anchors.fill: parent.fill
            anchors.bottomMargin: 20

            PrintModelInfoPage {
                startPrintButtonVisible: false
            }
        }


        // StartPrintPage.PrintFileDetails
        Item {
            id: startPrintPage2
            anchors.fill: parent.fill
            smooth: false

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

                /*InfoItem {
                    id: infill_info
                    labelText: qsTr("INFILL")
                    dataText: qsTr("99.99%")

                }

                InfoItem {
                    id: layer_height_info
                    labelText: qsTr("LAYER HEIGHT")
                    dataText: layer_height_mm

                }

                InfoItem {
                    id: shells_info
                    labelText: qsTr("SHELLS")
                    dataText: qsTr("2")
                }*/

                /*InfoItem {
                    id: model_info
                    labelText: qsTr("MODEL")
                    dataText: qsTr("%1 %2").arg(model_mass).arg(print_model_material_name)
                }

                InfoItem {
                    id: support_item
                    labelText: qsTr("SUPPORT")
                    dataText: qsTr("%1 %2").arg(support_mass).arg(print_support_material_name)

                }*/
            }
        }
    }

    PageIndicator {
        id: indicator
        smooth: false
        visible: startPrintSwipeView.visible
        count: startPrintSwipeView.count
        currentIndex: startPrintSwipeView.currentIndex
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle {
            implicitWidth: 12
            implicitHeight: 12

            radius: width / 2
            border.width: 1
            border.color: "#ffffff"
            color: index === indicator.currentIndex ? "#ffffff" : "#00000000"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
