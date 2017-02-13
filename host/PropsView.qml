import QtQuick 2.0
import QtQuick.Controls 2.0

// Somewhat generic view that lets you edit bot model properties
//
// Assumes that it is filling the entire width of our 440 wide window
// and doesn't really worry about running off the bottom end of the
// window.
//
// Properties that are not strings or numbers aren't really supported.
// Enums are supported as ints, so you don't get to view the enum names
// and you can set invalid enum values just fine.
//
// You have to pass in a BaseModel instance (like bot or bot.net) as
// bot_model, which must have metaInfo set by host_model
ListView {
    id: propsView
    x: 8
    width: 424
    height: 700
    property var bot_model: null
    model: bot_model.metaInfo
    delegate: Item {
        x: 5
        height: 40
        Row {
            id: row1
            spacing: 10
            Text {
                text: modelData.prop
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
            }
            TextField {
                id: propField
                placeholderText: bot_model[modelData.prop]
                onEditingFinished: {
                    var val, type = typeof(bot_model[modelData.prop]);
                    if (type == "number") val = Number(propField.text);
                    else val = propField.text;
                    bot_model[modelData.prop] = val;
                }
            }
        }
    }
}
