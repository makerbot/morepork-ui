import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ButtonRectangleBase {
    logKey: "ButtonRectangleSecondary"
    color: pressed ? "#FFFFFF" : "#000000"
    border.width: 2

    border.color: {
        (!enabled || style == ButtonRectangleBase.ButtonDisabledHelpEnabled) ?
                       "#808080" : "#FFFFFF"
    }
    textColor: {
        (!enabled || style == ButtonRectangleBase.ButtonDisabledHelpEnabled) ?
                   "#808080" : (pressed ? "#000000" : "#FFFFFF")
    }
}
