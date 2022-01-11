import QtQuick 2.12

Text {
    enum Style {
        Base,
        Bold
    }
    property int style: TextSubheader.Base
    id: textSubheader
    text: "Subheader"
    font.family: "Antenna"
    font.pixelSize: 16
    font.letterSpacing: {
        switch(style) {
        case TextSubheader.Base:
            3.2
            break;
        case TextSubheader.Bold:
            0.8
            break;
        default:
            3.2
        }
    }
    font.weight: {
        switch(style) {
        case TextSubheader.Base:
            Font.Light
            break;
        case TextSubheader.Bold:
            Font.Bold
            break;
        default:
            Font.Normal
        }
    }
    font.capitalization: {
        switch(style) {
        case TextSubheader.Base:
            Font.AllUppercase
            break;
        case TextSubheader.Bold:
            Font.MixedCase
            break;
        default:
            Font.AllUppercase
        }
    }
    horizontalAlignment: Text.AlignHCenter
    lineHeightMode: Text.FixedHeight
    lineHeight: 19.2
    color: Qt.rgba(255, 255, 255, 0.8)
}
