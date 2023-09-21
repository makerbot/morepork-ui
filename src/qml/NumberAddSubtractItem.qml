import QtQuick 2.0

NumberAddSubtractItemForm {

    function increaseValue() {
        value += 0.01
        value = round(value)
    }
    function decreaseValue() {
        value -= 0.01
        value = round(value)
    }

    // We have an issue that we are not
    // Printing 0.0 when we reach zero but
    // instead a really small number so round the
    // value to the nearest hundred at zero
    function round(value) {
        return Math.round(value*100)/100
    }
}
