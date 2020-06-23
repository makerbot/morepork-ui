import QtQuick 2.7
import QtQuick.Layouts 1.3

Item {
    property alias title: title
    property alias keys: keys
    property alias vals: vals
    property alias keyItem: keyItem
    property alias valItem: valItem
    property alias dateValItem: dateValItem
    property alias colorItem: colorItem

    property int index: 0
    property bool initialized: false

    width: parent.width/2

    Rectangle {
        anchors.fill: parent
        color: "#0000cc"
    }

    ColumnLayout {
        Text {
            id: title
            text: ""
            color: "#ffffff"
            font.letterSpacing: 1
            font.bold: true
            font.pixelSize: 15
        }

        RowLayout {
            id: contents
            spacing: 20

            ColumnLayout {
                id: keys
                Component {
                    id: keyItem

                    Text {
                        color: "#ffffff"
                        font.pixelSize: 12
                    }
                }
            }

            ColumnLayout {
                id: vals
                Component {
                    id: valItem

                    Text {
                        property string key: ""
                        property string unit: ""

                        text: key ? bot[key] + " " + unit : ""
                        color: "#ffffff"
                        font.pixelSize: 12
                    }
                }
                Component {
                    id: dateValItem

                    Text {
                        property string key: ""
                        property int daysSinceJan_1_2000: key ? bot[key] : 0

                        text: {
                            var sinceDate = new Date(2000, 0);
                            sinceDate.setDate(
                                    sinceDate.getDate() + daysSinceJan_1_2000);
                            var dateStr = sinceDate.toLocaleDateString();

                            // Assuming we get a format of:
                            // <Day of the week>, day month year, try to strip
                            // day of the week from the display string
                            var idx = dateStr.indexOf(',');
                            if (idx != -1) {
                                // (+2 to include the , and the space)
                                dateStr = dateStr.slice(
                                        idx + 2, dateStr.length);
                            }

                            return dateStr;
                        }
                        color: "#ffffff"
                        font.pixelSize: 12
                    }
                }
                Component {
                    id: colorItem
                    Rectangle {
                        property string key: ""

                        // sorry this looks sorta dumb. not sure if there's a
                        // better way to do this
                        property int r: key ? bot[key][0] : 0
                        property int g: key ? bot[key][1] : 0
                        property int b: key ? bot[key][2] : 0

                        border.width: 1
                        border.color: "#ffffff"
                        radius: 3
                        height: 12
                        width: 12

                        color: {
                            function toTwoDigitHex(val) {
                                return ("00" + val.toString(16)).substr(-2);
                            }
                            var colorStr = "#" + toTwoDigitHex(r)
                                               + toTwoDigitHex(g)
                                               + toTwoDigitHex(b);
                            return colorStr;
                        }
                    }
                }
            }
        }
    }

}
