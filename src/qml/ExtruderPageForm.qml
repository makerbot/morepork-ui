import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias defaultItem: tempItem
    smooth: false

    Item {
        id: tempItem
        property var backSwiper: mainSwipeView
        property int backSwipeIndex: 0
        smooth: false
    }
}
