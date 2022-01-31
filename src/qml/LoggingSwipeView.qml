import QtQuick 2.12
import QtQuick.Controls 2.5

SwipeView {
    smooth: false
    anchors.fill: parent
    interactive: false

    function swipeToItem(idx) {
        if(idx == currentIndex) {
            return
        }
        // For certain swipeviews there are special actions that
        // need to be done before swiping through depending on
        // current state of the bot. customEntryCheck function
        // is defined for such cases.
        if(typeof customEntryCheck === "function") {
            customEntryCheck(idx)
        }
        var prev = currentIndex
        itemAt(idx).visible = true
        setCurrentIndex(idx)
        itemAt(prev).visible = false
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
        setCurrentItem(itemAt(idx))
    }
}
