import QtQuick 2.0
import QtQuick.Controls 2.0

// Somewhat generic view that lets you edit bot model properties
//
// Assumes that it is filling the entire width of our 440 wide window
// and doesn't really worry about running off the bottom end of the
// window.
//
// You have to pass in a BaseModel instance (like bot or bot.net) as
// bot_model, which must have metaInfo set by host_model.cpp.  New
// types of model properties need support both here and there.
ListView {
    x: 8
    width: 424
    height: 700
    property var bot_model: null
    property string filter: ''
    model: {
        bot_model.metaInfo.filter((data) => {
            return filter == '' || data.prop.includes(filter)
        })
    }
    delegate: Item {
        x: 5
        height: 40
        property var prop : modelData.prop
        Row {
            spacing: 10
            Text {
                text: prop
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
            }
            Loader {
                active: modelData.chooser == "text"
                sourceComponent: Component {
                    TextField {
                        placeholderText: bot_model[prop]
                        property var text_fn : eval(modelData.text_fn)
                        onEditingFinished: bot_model[prop] = text_fn(text)
                    }
                }
            }
            Loader {
                active: modelData.chooser == "combo"
                sourceComponent: Component {
                    ComboBox {
                        model: modelData.combo
                        currentIndex: bot_model[prop]
                        onActivated: bot_model[prop] = currentIndex
                    }
                }
            }
            Loader {
                active: modelData.chooser == "check"
                sourceComponent: Component {
                    CheckBox {
                        checked: bot_model[prop]
                        onClicked: bot_model[prop] = checked
                    }
                }
            }
        }
    }
}
