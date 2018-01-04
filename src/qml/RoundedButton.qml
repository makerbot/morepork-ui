import QtQuick 2.4

RoundedButtonForm {

    button_mouseArea {
        onPressed: {
            button_rectangle.color = "#ffffff"
            button_rectangle.border.color = "#000000"
            button_text.color = "#000000"
        }

        onReleased: {
            button_rectangle.color = "#00000000"
            button_rectangle.border.color = "#ffffff"
            button_text.color = "#ffffff"
        }
    }
}
