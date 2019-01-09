import QtQuick 2.10

RoundedButtonForm {
    button_mouseArea {
        onPressed: {
            if(!disable_button) {
                button_rectangle.color = button_pressed_color
                button_rectangle.border.color = "#000000"
                button_text.color = "#000000"
            }
        }

        onReleased: {
            if(!disable_button) {
                button_rectangle.color = is_button_transparent ? "#00000000" : button_not_pressed_color
                button_rectangle.border.color = "#ffffff"
                button_text.color = "#ffffff"
            }
        }
    }
}
