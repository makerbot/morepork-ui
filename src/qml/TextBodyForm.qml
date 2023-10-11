import QtQuick 2.12
import QtQuick.Layouts 1.12

Text {
    enum Style {
        Base,
        Large,
        ExtraLarge
    }
    property int style: TextBody.Base
    id: textBody
    text: "text-base"
    font.family: "Antenna"
    font.pixelSize: {
        switch(style) {
        case TextBody.Base:
            15
            break;
        case TextBody.Large:
            18
            break;
        case TextBody.ExtraLarge:
            22
            break;
        default:
            15
        }
    }

    lineHeightMode: Text.FixedHeight
    wrapMode: Text.WordWrap
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
    color: "#ffffff"

    // Due to binding error we set the spacing onCompleted
    Component.onCompleted: {
        font.letterSpacing = setLetterSpacing()
    }

    function setLetterSpacing() {
        var spacing = 1;
        switch(style) {
        case TextBody.Base:
            spacing = (font.weight == Font.Bold ? 1.8 : 1);
            break;
        case TextBody.Large:
            spacing = (font.weight == Font.Bold ? 1.8 : 1.1);
            break;
        case TextBody.ExtraLarge:
            spacing = (font.weight == Font.Bold ? 2.2 : 1.3);
            break;
        default:
            spacing = 1
            break;
        }
        return spacing;
    }

}
