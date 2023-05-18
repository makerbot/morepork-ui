import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: infoItem
    width: 680
    smooth: false
    antialiasing: false

    property alias labelText: labelText.text
    property alias dataText: dataText.text
    property alias dataElement: dataText
    property alias labelElement: labelText
    property alias baseElement: baseItem

    RowLayout {
        id: baseItem
        width: parent.width
        spacing: 50

        TextBody {
            style: TextBody.Base
            font.weight: Font.Light
            id: labelText
            text: "label"
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.minimumWidth: 270
        }

        TextBody {
            style: TextBody.Base
            font.weight: Font.Bold
            id: dataText
            text: "data"
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            elide: Text.ElideRight
            Layout.minimumWidth: 365

            // local override of wrapping until wider testing can be done
            wrapMode: {
                if (text == "FILENAME") {
                    Text.Wrap
                } else {
                    Text.WordWrap
                }
            }
        }
    }
}
