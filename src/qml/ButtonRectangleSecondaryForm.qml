import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ButtonRectangleBase {
    logKey: "ButtonRectangleSecondary"
    color: "#000000"
    border.width: 2
    border.color: enabled ? (pressed ? "#B2B2B2" : "#FFFFFF") : "#808080"
    textColor: enabled ? (pressed ? "#B2B2B2" : "#FFFFFF") : "#808080"
}
