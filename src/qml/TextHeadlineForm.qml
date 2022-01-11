import QtQuick 2.12

Text {
    enum Style {
        Base,
        Large
    }
    property int style: TextHeadline.Base
    id: textHeadline
    text: "HEADLINE"
    font.family: "Antenna"
    font.styleName: "Light"
    font.pixelSize: {
        switch(style) {
        case TextHeadline.Base:
            20
            break;
        case TextHeadline.Large:
            30
            break;
        default:
            20
        }
    }
    font.letterSpacing: {
        switch(style) {
        case TextHeadline.Base:
            2
            break;
        case TextHeadline.Large:
            6
            break;
        default:
            2
        }
    }
    font.weight: Font.Bold
    lineHeightMode: Text.FixedHeight
    lineHeight: {
        switch(style) {
        case TextHeadline.Base:
            24
            break;
        case TextHeadline.Large:
            36
            break;
        default:
            24
        }
    }
    horizontalAlignment: Text.AlignHCenter
    color: Qt.rgba(255, 255, 255, 0.8)
}
