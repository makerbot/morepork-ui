import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: languageButton
    width: parent.width
    height: 80
    smooth: false

    onClicked: {
        translate.selectLanguage(localeCode)
        settings.setLanguageCode(localeCode)

        // currentLocale is referenced from the parent page
        // 'LanguageSelectorForm.qml' which is a bad thing
        // to do in qml as the refernece will be silently
        // lost when this child is reused elesewhere and
        // only fail at runtime.

        // The locale name can only be accessed from
        // the constructed object
        currentLocale = Qt.locale().name
    }

    property alias isSelected: isSelectedImage.visible
    property alias languageName: languageNameText.text
    property string localeCode: "en_GB"
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: languageButton.down ? 1 : 0
        color: languageButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
        anchors.topMargin: 0
        smooth: false
    }

    Image {
        id: isSelectedImage
        width: 34
        height: 34
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 32
        source: "qrc:/img/check_circle_small.png"

        // This convoulted method of determining the locale
        // had to be used because the only way of getting
        // the current locale in qml is through the
        // the constructed object returned by Qt.locale()
        // rather than a signal based updation of the
        // locale whenever it changes.
        visible: currentLocale == localeCode
    }

    Text {
        id: languageNameText
        text: "LANGUAGE"
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }
}
