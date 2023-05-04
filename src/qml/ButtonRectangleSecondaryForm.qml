import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ButtonRectangleBase {
    logKey: "ButtonRectangleSecondary"
    color: "#000000"
    border.width: 2
    border.color: {
        (!enabled || style == ButtonRectangleBase.ButtonDisabledHelpEnabled) ?
                       "#808080" : (pressed ? "#B2B2B2" : "#FFFFFF")
    }
    textColor: {
        (!enabled || style == ButtonRectangleBase.ButtonDisabledHelpEnabled) ?
                   "#808080" : (pressed ? "#B2B2B2" : "#FFFFFF")
    }
}
