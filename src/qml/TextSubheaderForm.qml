import QtQuick 2.12
import QtQuick.Layouts 1.12

Text {
    enum Style {
        Base,
        Bold,
        TopBar
    }
    property int style: TextSubheader.Base
    id: textSubheader
    text: "Subheader"
    font.family: "Antenna"
    font.pixelSize: {
        switch(style) {
        case TextSubheader.TopBar:
            17
            break;
        default:
            16
            break;
        }
    }
    font.letterSpacing: {
        switch(style) {
        case TextSubheader.Base:
            3.2
            break;
        case TextSubheader.Bold:
            0.8
            break;
        case TextSubheader.TopBar:
            3
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
        case TextSubheader.TopBar:
            Font.Light
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
        case TextSubheader.TopBar:
            Font.AllUppercase
            break;
        default:
            Font.AllUppercase
        }
    }
    horizontalAlignment: Text.AlignHCenter
    lineHeightMode: Text.FixedHeight
    lineHeight: {
        switch(style) {
        case TextSubheader.TopBar:
            22
            break;
        default:
            19.2
            break;
        }
    }
    color: Qt.rgba(255, 255, 255, 0.9)
}
