import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ButtonRectangleBase {
    logKey: "ButtonRectanglePrimary"
    color: {
        (!enabled || style == ButtonRectangleBase.ButtonDisabledHelpEnabled) ?
               "#808080" : (pressed ? "#B2B2B2" : "#FFFFFF")
    }
}
