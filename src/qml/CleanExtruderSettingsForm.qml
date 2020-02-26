import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false

    property alias defaultItem: itemCleanExtrudersSelectMaterial
    property alias cleanExtruderMaterialSelectorPage: cleanExtruderMaterialSelectorPage
    property alias cleanExtruderTempSelectorPage: cleanExtruderTempSelectorPage
    property alias cleanExtrudersSelectMaterialSwipeView: cleanExtrudersSelectMaterialSwipeView

    SwipeView {
        id: cleanExtrudersSelectMaterialSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = cleanExtrudersSelectMaterialSwipeView.currentIndex
            cleanExtrudersSelectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            if(itemToDisplayDefaultIndex == 0) {
                setCurrentItem(advancedSettingsSwipeView.itemAt(9))
            } else {
                setCurrentItem(cleanExtrudersSelectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
            cleanExtrudersSelectMaterialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            cleanExtrudersSelectMaterialSwipeView.itemAt(prevIndex).visible = false
        }

        // cleanExtrudersSelectMaterialSwipeView.index = 0
        Item {
            id: itemCleanExtrudersSelectMaterial
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: true

            CleanExtruderMaterialSelector {
                id: cleanExtruderMaterialSelectorPage

            }
        }

        // cleanExtrudersSelectMaterialSwipeView.index = 1
        Item {
            id: itemCleanExtrudersSelectCustomTemperature
            property var backSwiper: cleanExtrudersSelectMaterialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            CleanExtruderTempSelector {
                id: cleanExtruderTempSelectorPage

            }
        }
    }
}
