import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

RowLayout {
    width: parent.width
    height: children.height
    spacing: 10

    property alias currentValue: currentValue.text
    property alias lifetimeValue: lifetimeValue.text
    property alias descriptor: lifetimeValueDescriptor.text
    property bool exceededLifetimeValue: false

    ColumnLayout {
        spacing: 5

        TextBody {
            id: currentValue
            font.weight: Font.Bold
            color: exceedLifetimeValue ? "#FCA833" : "#FFFFFF"
        }
        TextBody {
            text: "Current"
            font.weight: Font.Bold
            color: exceedLifetimeValue ? "#FCA833" : "#FFFFFF"
        }
    }
    ColumnLayout {
        spacing: 5

        TextBody {
            text: "|"
        }
        TextBody {
            text: "|"
        }
    }
    ColumnLayout {
        spacing: 5

        TextBody {
            id: lifetimeValue
            text: "1000"
        }
        TextBody {
            id: lifetimeValueDescriptor
            text: qsTr("Lifetime (Hours)")
        }
    }
}


