import QtQuick 2.10

Item {
    smooth: false
    anchors.fill: parent

    property variant timeZones: [
        {name: "AMERICAS"},
        {code: "HST", name: "HAWAII STANDARD TIME", GMTOffset: "GMT-10:00", path: "US/Hawaii"},
        {code: "AST", name: "ALASKA STANDARD TIME", GMTOffset: "GMT-9:00", path: "US/Alaska"},
        {code: "PST", name: "PACIFIC STANDARD TIME", GMTOffset: "GMT-8:00", path: "US/Pacific"},
        {code: "PNT", name: "PHOENIX STANDARD TIME", GMTOffset: "GMT-7:00", path: "US/Arizona"},
        {code: "MST", name: "MOUNTAIN STANDARD TIME", GMTOffset: "GMT-7:00", path: "US/Mountain"},
        {code: "CST", name: "CENTRAL STANDARD TIME", GMTOffset: "GMT-6:00", path: "US/Central"},
        {code: "EST", name: "EASTERN STANDARD TIME", GMTOffset: "GMT-5:00", path: "US/Eastern"},
        {code: "CNT", name: "CANADA NEWFOUNDLAND TIME", GMTOffset: "GMT-3:30", path: "Canada/Newfoundland"},
        {code: "BET", name: "BRAZIL EASTERN TIME", GMTOffset: "GMT-3:00", path: "Brazil/East"},
        {name: "EUROPE"},
        {code: "WET", name: "WESTERN EUROPEAN TIME", GMTOffset: "GMT", path: "Europe/London"},
        {code: "CET", name: "EUROPEAN CENTRAL TIME", GMTOffset: "GMT+1:00", path: "Europe/Berlin"},
        {code: "EET", name: "EASTERN EUROPEAN TIME", GMTOffset: "GMT+2:00", path: "Europe/Kiev"},
        {name: "MIDDLE EAST"},
        {code: "AST", name: "ARABIA STANDARD TIME", GMTOffset: "GMT+3:00", path: "Turkey"},
        {code: "GST", name: "GULF STANDARD TIME", GMTOffset: "GMT+4:00", path: "Asia/Dubai"},
        {name: "ASIA"},
        {code: "PKT", name: "PAKISTAN STANDARD TIME", GMTOffset: "GMT+5:00", path: "Asia/Karachi"},
        {code: "IST", name: "INDIA STANDARD TIME", GMTOffset: "GMT+5:30", path: "Asia/Calcutta"},
        {code: "BST", name: "BANGLADESH STANDARD TIME", GMTOffset: "GMT+6:00", path: "Asia/Dhaka"},
        {code: "ICT", name: "INDOCHINA TIME", GMTOffset: "GMT+7:00", path: "Asia/Bangkok"},
        {code: "CHN", name: "CHINA STANDARD TIME", GMTOffset: "GMT+8:00", path: "Asia/Shanghai"},
        {code: "JST", name: "JAPAN STANDARD TIME", GMTOffset: "GMT+9:00", path: "Asia/Tokyo"},
        {name: "AUSTRALIA"},
        {code: "ACT", name: "AUSTRALIA CENTRAL TIME", GMTOffset: "GMT+9:30", path: "Australia/Adelaide"},
        {code: "AET", name: "AUSTRALIA EASTERN TIME", GMTOffset: "GMT+10:00", path: "Australia/Sydney"},
        {code: "NST", name: "NEW ZEALAND STANDARD TIME", GMTOffset: "GMT+12:00", path: "Pacific/Auckland"},
    ]

    LoggingStackLayout {
        logName: "timeZoneSelector"
        Item {
            ListSelector {
                id: timeZoneSelector
                model: timeZones
                delegate:
                MenuButton {
                    id: timeZoneButton
                    buttonText.text: {
                        if(modelData["code"]) {
                            (modelData["code"] + "\t" +
                            modelData["name"] + "\t" +
                            modelData["GMTOffset"])
                        } else {
                            modelData["name"]
                        }
                    }
                    buttonImage {
                        source: "qrc:/img/selected_checkmark.png"
                        visible: bot.timeZone == modelData["path"]
                    }
                    onClicked: {
                        if(modelData["path"]) {
                            setTimeZone(modelData["path"])
                        }
                    }
                }
            }
        }
    }
}
