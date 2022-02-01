import QtQuick 2.12

Text {
    id: textHuge
    text: "TEXT-HUGE"
    font.family: "Antenna"
    font.pixelSize: 120
    font.weight: Font.Light
    font.letterSpacing: 7.2 // 6% of pixel size in px
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignTop
    lineHeightMode: Text.FixedHeight
    lineHeight: 144
    color: "#FFFFFF"
}
