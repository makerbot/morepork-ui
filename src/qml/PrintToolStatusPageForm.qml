import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

GridLayout {
    property int extACurrentTemp: -999
    property int extATargetTemp: -999

    property int extBCurrentTemp: -999
    property int extBTargetTemp: -999

    property int chamberCurrentTemp: -999
    property int chamberTargetTemp: -999

    property bool hasHbp: false
    property int hbpCurrentTemp: -999
    property int hbpTargetTemp: -999

    anchors.fill: parent
    columns: 2
    rows: 2
    width: parent.width
    smooth: false
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 10
    anchors.bottomMargin: 40
    anchors.leftMargin: 60
    anchors.rightMargin: 60
    columnSpacing: 50

        PrintToolStatusItem {
            Layout.preferredWidth: parent.width * 0.5
            //Layout.preferredHeight: parent.height * 0.5
            toolName: qsTr("EXTRUDER 1")
            currentTemp: extACurrentTemp
            targetTemp: extATargetTemp
        }
        PrintToolStatusItem {
            Layout.preferredWidth: parent.width * 0.5
            //Layout.preferredHeight: parent.height * 0.5
            toolName: qsTr("EXTRUDER 2")
            currentTemp: extBCurrentTemp
            targetTemp: extBTargetTemp
        }

        PrintToolStatusItem {
            Layout.preferredWidth: parent.width * 0.5
            //Layout.preferredHeight: parent.height * 0.5
            toolName: qsTr("CHAMBER")
            currentTemp: chamberCurrentTemp
            targetTemp: chamberTargetTemp
        }
        PrintToolStatusItem {
            Layout.preferredWidth: parent.width * 0.5
            //Layout.preferredHeight: parent.height * 0.5
            visible: hasHbp
            toolName: qsTr("BUILD PLATE")
            currentTemp: hbpCurrentTemp
            targetTemp: hbpTargetTemp
        }
}

