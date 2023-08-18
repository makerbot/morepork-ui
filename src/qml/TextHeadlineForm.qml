import QtQuick 2.12
import QtQuick.Layouts 1.12

Text {
    enum Style {
        Base,
        Large,
        ExtraLarge,
        TopBar
    }
    property int style: TextHeadline.Base
    id: textHeadline
    text: "HEADLINE"
    font.family: "Antenna"
    font.pixelSize: {
        switch(style) {
        case TextHeadline.Base:
            20
            break;
        case TextHeadline.Large:
            30
            break;
        case TextHeadline.ExtraLarge:
            48
            break;
        case TextSubheader.TopBar:
            17
            break;
        default:
            20
        }
    }
    verticalAlignment: Text.AlignVCenter
    font.letterSpacing: {
        switch(style) {
        case TextHeadline.Base:
            2
            break;
        case TextHeadline.Large:
            6
            break;
        case TextHeadline.ExtraLarge:
            7.2
            break;
        case TextSubheader.TopBar:
            3
            break;
        default:
            2
        }
    }
    font.weight: {
        switch(style) {
        case TextHeadline.TopBar:
        default:
            Font.DemiBold
            break;
        }
    }
    font.capitalization: Font.AllUppercase
    wrapMode: Text.WordWrap
    lineHeightMode: Text.FixedHeight
    lineHeight: {
        switch(style) {
        case TextHeadline.Base:
            24
            break;
        case TextHeadline.Large:
            36
            break;
        case TextHeadline.ExtraLarge:
            52
            break;
        case TextSubheader.TopBar:
            22
            break;
        default:
            24
        }
    }
    color: Qt.rgba(255, 255, 255, 0.9)
}
