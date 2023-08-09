import QtQuick 2.0

NumberAddSubtractItemForm {

    function increaseValue() {
        value += 0.01
    }
    function decreaseValue() {
        value-= 0.01
    }

}
