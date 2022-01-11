import QtQuick 2.12

Text {
    enum Style {
        Base,
        Large,
        ExtraLarge
    }
    property int style: TextBody.Base
    id: textBody
    text: "text-base"
    font.family: "Roboto"
    font.styleName: "Light"
    font.pixelSize: {
        switch(style) {
        case TextBody.Base:
            16
            break;
        case TextBody.Large:
            18
            break;
        case TextBody.ExtraLarge:
            22
            break;
        default:
            16
        }
    }
    font.letterSpacing: {
        switch(style) {
        case TextBody.Base:
            font.weight == Font.Bold ? 1.8 : 1
            break;
        case TextBody.Large:
            font.weight == Font.Bold ? 1.8 : 1.1
            break;
        case TextBody.ExtraLarge:
            font.weight == Font.Bold ? 2.2 : 1.3
            break;
        default:
            1
        }
    }
    lineHeightMode: Text.FixedHeight
    lineHeight: {
        switch(style) {
        case TextBody.Base:
            20
            break;
        case TextBody.Large:
            22
            break;
        case TextBody.ExtraLarge:
            26
            break;
        default:
            20
        }
    }
    horizontalAlignment: Text.AlignHCenter
    color: Qt.rgba(255, 255, 255, 0.8)
}
