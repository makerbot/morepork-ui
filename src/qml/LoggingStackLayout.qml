import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

StackLayout {
    id: stackLayout
    // Enums in QML can only be defined in the root item of a
    // component/page. itemWithEnum should point to the item
    // that contains the enum used for this swipeview' swipe
    // index, which is generally the parent item for most of
    // the swipeviews. The mainSwipeView is the only exception,
    // since it is one extra level deeper in the root item of
    // the UI.
    property var itemWithEnum: parent
    property string logName: "defaultName"
    smooth: false
    anchors.fill: parent

    function swipeToItem(idx, setTargetAsCurrentItem=true) {
        logAction("Swipe requested to page", idx)
        if(idx == currentIndex) {
            logAction("Warning: Already on requested page", idx)
            return
        }
        // For certain swipeviews there are special actions that
        // need to be done before swiping through depending on
        // current state of the bot. customEntryCheck function
        // is defined for such cases.
        if(typeof customEntryCheck === "function") {
            customEntryCheck(idx)
        }
        itemAt(currentIndex).opacity = 0
        itemAt(currentIndex).visible = false
        itemAt(idx).visible = true
        currentIndex = idx
        animation.restart()
        logAction("Swiped to page", currentIndex)
        // Usually the page that is swiped to is set as the current
        // item. The current item determines what the back button
        // should do on that page. But due to having nested swipeviews,
        // sometimes we need to explictly set the current item as the
        // base item in the parent swipeview that holds the swiped-to
        // page, which is what the customSetCurrentItem function does.
        // This function needs to return true if it sets another item
        // as the current item.
        if(typeof customSetCurrentItem === "function" && customSetCurrentItem(idx)) {
            return
        }
        // The default behavior is to set the target being swiped to as
        // the current item (which defines the appropriate back button
        // behavior) unless we are swiping to just reset the pages.
        if (setTargetAsCurrentItem) {
            setCurrentItem(itemAt(idx))
        }
    }

    function logAction(action, idx) {
        console.info(logName, action, log.getEnumName(itemWithEnum, "SwipeIndex", idx))
    }

    NumberAnimation {
        id: animation
        target: itemAt(currentIndex)
        property: "opacity"
        to: 1
        duration: 125
    }

    Component.onCompleted: {
       for(var i = 1; i < count; ++i) {
           children[i].opacity = 0
       }
    }
}
