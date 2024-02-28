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
        {code: "AGT", name: "ARGENTINA STANDARD TIME", GMTOffset: "GMT-3:00", path: "Etc/GMT-3"},
        {code: "BET", name: "BRAZIL EASTERN TIME", GMTOffset: "GMT-3:00", path: "Etc/GMT-3"},
        {name: "EUROPE"},
        {code: "CAT", name: "CENTRAL AFRICAN TIME", GMTOffset: "GMT-1:00", path: "Etc/GMT-1"},
        {code: "GMT", name: "GREENWICH MEAN TIME", GMTOffset: "GMT", path: "UTC"},
        {code: "ECT", name: "EUROPEAN CENTRAL TIME", GMTOffset: "GMT+1:00", path: "Etc/GMT+1"},
        {code: "EET", name: "EASTERN EUROPEAN TIME", GMTOffset: "GMT+2:00", path: "Etc/GMT+2"},
        {name: "MIDDLE EAST"},
        {code: "ART", name: "(ARABIC) EGYPT STANDARD TIME", GMTOffset: "GMT+2:00", path: "Etc/GMT+2"},
        {code: "EAT", name: "EASTERN AFRICAN TIME", GMTOffset: "GMT+3:00", path: "Etc/GMT+3"},
        {code: "MET", name: "MIDDLE EAST TIME", GMTOffset: "GMT+3:30", path: "Iran"},
        {code: "NET", name: "NEAR EAST TIME", GMTOffset: "GMT+4:00", path: "Etc/GMT+4"},
        {name: "ASIA"},
        {code: "PLT", name: "PAKISTAN LAHORE TIME", GMTOffset: "GMT+5:00", path: "Etc/GMT+5"},
        {code: "IST", name: "INDIA STANDARD TIME", GMTOffset: "GMT+5:30", path: "Asia/Calcutta"},
        {code: "BST", name: "BANGLADESH STANDARD TIME", GMTOffset: "GMT+6:00", path: "Etc/GMT+6"},
        {code: "VST", name: "VIETNAM STANDARD TIME", GMTOffset: "GMT+7:00", path: "Etc/GMT+7"},
        {code: "CHN", name: "CHINA STANDARD TIME", GMTOffset: "GMT+8:00", path: "Etc/GMT+8"},
        {code: "JST", name: "JAPAN STANDARD TIME", GMTOffset: "GMT+9:00", path: "Etc/GMT+9"},
        {name: "AUSTRALIA"},
        {code: "ACT", name: "AUSTRALIA CENTRAL TIME", GMTOffset: "GMT+9:30", path: "Australia/ACT"},
        {code: "AET", name: "AUSTRALIA EASTERN TIME", GMTOffset: "GMT+10:00", path: "Etc/GMT+10"},
        {code: "SST", name: "SOLOMON STANDARD TIME", GMTOffset: "GMT+11:00", path: "Etc/GMT+11"},
        {code: "NST", name: "NEW ZEALAND STANDARD TIME", GMTOffset: "GMT+12:00", path: "Etc/GMT+12"},
        {code: "MIT", name: "MIDWAY ISLANDS TIME", GMTOffset: "GMT-11:00", path: "Etc/GMT-11"},
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
