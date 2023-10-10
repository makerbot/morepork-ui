import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9

Drawer {
    width: rootAppWindow.width
    height: rootAppWindow.height - topBar.height
    edge: rootItem.rotation == 180 ? Qt.BottomEdge : Qt.TopEdge
    dim: false
    interactive: false

    property string topBarTitle: ""

    background:
        Rectangle {
            rotation: rootItem.rotation == 180 ? 180 : 0
            smooth: false
            gradient: Gradient {
                      GradientStop { position: 0.0; color: "#00000000" }
                      GradientStop { position: 0.166; color: "#00000000" }
                      GradientStop { position: 0.167; color: "#000000" }
                      GradientStop { position: 1; color: "#000000" }
                  }
            }

    onOpened: {
        // Drawer can be closed by swiping when in the open state.
        interactive = true
        topBar.backButton.visible = false
        drawerState = MoreporkUI.DrawerState.Open
    }

    onClosed: {
        // Drawer cannot be opened by swiping on the drawer handle at the
        // edge of the screen when in the closed state. We instaed repurpose
        // a flickable to open the drawer on swiping from the edge.
        interactive = false
        drawerState = MoreporkUI.DrawerState.Closed
        if(mainSwipeView.currentIndex != MoreporkUI.BasePage) {
            topBar.backButton.visible = true
        }
    }
}
