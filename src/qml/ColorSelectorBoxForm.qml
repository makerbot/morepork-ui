import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: colorItem
    width: 400
    height: 100
    anchors.horizontalCenter: parent.horizontalCenter

    property alias colorText: colorText.text
    property alias value: colorSpinBox.value
    property alias colorSlider: colorSlider
    property int maxColorValue: 255

    Text {
        id: colorText
        color: "#ffffff"
        text: qsTr("COLOR")
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25
        font.pixelSize: 30
    }

    ColumnLayout {
        id: columnLayout1
        width: 325
        height: 100
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 75

        SpinBox {
            id: colorSpinBox
            font.pointSize: 20
            font.family: "Tahoma"
            font.bold: true
            value: colorSlider.value
            to: maxColorValue
            stepSize: 1
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        Slider {
            id: colorSlider
            to: maxColorValue
            stepSize: 1
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            value: colorSpinBox.value
        }
    }
}
