import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    width: rootAppWindow.width
    height: rootAppWindow.height

    // Defined set of points for test
    property var points: [
        {'x': 100,'y': 100},
        {'x': 300,'y': 100},
        {'x': 500,'y': 100},
        {'x': 700,'y': 100},
        {'x': 700,'y': 300},
        {'x': 500,'y': 300},
        {'x': 300,'y': 300},
        {'x': 100,'y': 300}
    ]
    property var offsetsX: []
    property var offsetsY: []
    property int pointIndex: 0
    property bool finished: false
    property real avgOffsetX: 0
    property real avgOffsetY: 0
    property real distance: 0

    function resetTouchTest() {
        pointIndex = 0
        finished = false
        distance = 0
        avgOffsetX = 0
        avgOffsetY = 0
        offsetsX = []
        offsetsY = []
    }

    Item {
       id: touchTest
       width: parent.width
       height: parent.height

       Rectangle {
           id: touchCircle
           color: "white"
           visible: pointIndex < 8 && !finished
           x: points[pointIndex].x- width / 2
           y: points[pointIndex].y - height / 2
           width: 50
           height: width
           radius: width / 2
       }

       TapHandler {
           id: tapHandlerScreen
           acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Mouse
           onTapped: {
               if(!finished) {
                   // Get difference between tap and defined point
                   // and add to array
                   var diff = point.position.x - points[pointIndex].x
                   offsetsX.push(diff)
                   diff = points[pointIndex].y - point.position.y
                   offsetsY.push(diff)

                   // Increase points index
                   if(pointIndex < 7) {
                       pointIndex++
                   }
                   else {
                       pointIndex = 0

                       // Average the offsets of X and Y
                       for(var i=0; i<8; i++) {
                           avgOffsetX += offsetsX[i]
                           avgOffsetY += offsetsY[i]
                       }
                       // Divide and finish test
                       avgOffsetX /= 8
                       avgOffsetY /= 8

                       // Get distance (hypotenuse)
                       var distSq = avgOffsetX*avgOffsetX + avgOffsetY*avgOffsetY
                       distance = Math.sqrt(distSq)

                       // Set flag to finished
                       finished = true
                   }
               }
           }

       }

       ColumnLayout {
           spacing: 10
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           anchors.verticalCenterOffset: -80
           visible: finished

           TitleText {
               id: textOffsetInPixels
               text: qsTr("Average Offsets in Pixels")
           }

           RowLayout {
               spacing: 15
               Layout.alignment: Qt.AlignHCenter

               ColumnLayout {
                   spacing: 10
                   TextHeadline {
                       id: textHeaderDist
                       text: "D:"
                   }

                   TextHeadline {
                       id: textHeaderX
                       text: "X:"
                   }
                   TextHeadline {
                       id: textHeaderY
                       text: "Y:"
                   }
               }
               ColumnLayout {
                   spacing: 15

                   TextSubheader {
                       id: textDistance
                       text: Math.round(distance)
                   }

                   TextSubheader {
                       id: textAvgOffX
                       text: Math.round(avgOffsetX)
                   }

                   TextSubheader {
                       id: textAvgOffY
                       text: Math.round(avgOffsetY)
                   }
               }
           }
       }

       RoundedButton {
           id: finishedButton
           buttonWidth: 200
           buttonHeight: 70
           forceButtonWidth: true
           button_mouseArea.onClicked: {
               systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
               resetTouchTest()
           }
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           anchors.verticalCenterOffset: 50
           visible: finished

           label: qsTr("DONE")
        }
    }
}
