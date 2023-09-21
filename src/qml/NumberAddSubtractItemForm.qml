import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    property alias numberValue: numberValue
    property double value: 0.20
    width: parent.width

    RowLayout {
        width: children.width
        spacing: 48

        Image {
            id: minusImage
            width: sourceSize.width
            height: sourceSize.height
            Layout.preferredHeight: height
            Layout.preferredWidth: width
            source:  "qrc:/img/minus_circle.png"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    decreaseValue()
                }
            }
        }
        TextBody {
            id: numberValue
            width: 114
            Layout.preferredWidth: width

            horizontalAlignment: Text.AlignHCenter
            text: qsTr("%1").arg(value)
            font.pixelSize: 42
            //font.family: "Antenna"
            lineHeight: 49.22
        }

        Image {
            id: plusImage
            width:  sourceSize.width
            height:  sourceSize.height
            Layout.preferredHeight: height
            Layout.preferredWidth: width
            source: "qrc:/img/plus_circle.png"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    increaseValue()
                }
            }
        }

    }

}
