import QtQuick 2.10

Item {
    anchors.fill: parent

    Flickable {
        id: flickableTimeZone
        smooth: false
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.fill: parent
        contentHeight: columnTimeZone.height

        Column {
            id: columnTimeZone
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            // Americas
            TimeZoneLocationSeparator {
                region: "AMERICAS"
            }

            TimeZoneButton {
                id: buttonTimeZone_HST
                timeZoneCode: "HST"
                timeZoneName: "HAWAII STANDARD TIME"
                timeZoneGMTReference: "GMT-10:00"
                timeZonePathName: "US/Hawaii"
            }

            TimeZoneButton {
                id: buttonTimeZone_AST
                timeZoneCode: "AST"
                timeZoneName: "ALASKA STANDARD TIME"
                timeZoneGMTReference: "GMT-9:00"
                timeZonePathName: "US/Alaska"
            }

            TimeZoneButton {
                id: buttonTimeZone_PST
                timeZoneCode: "PST"
                timeZoneName: "PACIFIC STANDARD TIME"
                timeZoneGMTReference: "GMT-8:00"
                timeZonePathName: "US/Pacific"
            }

            TimeZoneButton {
                id: buttonTimeZone_PNT
                timeZoneCode: "PNT"
                timeZoneName: "PHOENIX STANDARD TIME"
                timeZoneGMTReference: "GMT-7:00"
                timeZonePathName: "US/Arizona"
            }

            TimeZoneButton {
                id: buttonTimeZone_MST
                timeZoneCode: "MST"
                timeZoneName: "MOUNTAIN STANDARD TIME"
                timeZoneGMTReference: "GMT-7:00"
                timeZonePathName: "US/Mountain"
            }

            TimeZoneButton {
                id: buttonTimeZone_CST
                timeZoneCode: "CST"
                timeZoneName: "CENTRAL STANDARD TIME"
                timeZoneGMTReference: "GMT-6:00"
                timeZonePathName: "US/Central"
            }

            TimeZoneButton {
                id: buttonTimeZone_EST
                timeZoneCode: "EST"
                timeZoneName: "EASTERN STANDARD TIME"
                timeZoneGMTReference: "GMT-5:00"
                timeZonePathName: "US/Eastern"
            }

            TimeZoneButton {
                id: buttonTimeZone_IET
                timeZoneCode: "IET"
                timeZoneName: "INDIANA EASTERN STANDARD TIME"
                timeZoneGMTReference: "GMT-5:00"
                timeZonePathName: "US/East-Indiana"
            }

            TimeZoneButton {
                id: buttonTimeZone_PRT
                timeZoneCode: "PRT"
                timeZoneName: "PUERTO RICO & US VIRGIN ISLANDS TIME"
                timeZoneGMTReference: "GMT-4:00"
                timeZonePathName: "Etc/GMT-4"
            }

            TimeZoneButton {
                id: buttonTimeZone_CNT
                timeZoneCode: "CNT"
                timeZoneName: "CANADA NEWFOUNDLAND TIME"
                timeZoneGMTReference: "GMT-3:30"
                timeZonePathName: "Canada/Newfoundland"
            }

            TimeZoneButton {
                id: buttonTimeZone_AGT
                timeZoneCode: "AGT"
                timeZoneName: "ARGENTINA STANDARD TIME"
                timeZoneGMTReference: "GMT-3:00"
                timeZonePathName: "Etc/GMT-3"
            }

            TimeZoneButton {
                id: buttonTimeZone_BET
                timeZoneCode: "BET"
                timeZoneName: "BRAZIL EASTERN TIME"
                timeZoneGMTReference: "GMT-3:00"
                timeZonePathName: "Etc/GMT-3"
            }

            // Europe
            TimeZoneLocationSeparator {
                region: "EUROPE"
            }

            TimeZoneButton {
                id: buttonTimeZone_CAT
                timeZoneCode: "CAT"
                timeZoneName: "CENTRAL AFRICAN TIME"
                timeZoneGMTReference: "GMT-1:00"
                timeZonePathName: "Etc/GMT-1"
            }

            TimeZoneButton {
                id: buttonTimeZone_GMT
                timeZoneCode: "GMT"
                timeZoneName: "GREENWICH MEAN TIME"
                timeZoneGMTReference: "GMT"
                timeZonePathName: "UTC"
            }

            TimeZoneButton {
                id: buttonTimeZone_ECT
                timeZoneCode: "ECT"
                timeZoneName: "EUROPEAN CENTRAL TIME"
                timeZoneGMTReference: "GMT+1:00"
                timeZonePathName: "Etc/GMT+1"
            }

            TimeZoneButton {
                id: buttonTimeZone_EET
                timeZoneCode: "EET"
                timeZoneName: "EASTERN EUROPEAN TIME"
                timeZoneGMTReference: "GMT+2:00"
                timeZonePathName: "Etc/GMT+2"
            }

            // Middle East
            TimeZoneLocationSeparator {
                region: "MIDDLE EAST"
            }

            TimeZoneButton {
                id: buttonTimeZone_ART
                timeZoneCode: "ART"
                timeZoneName: "(ARABIC) EGYPT STANDARD TIME"
                timeZoneGMTReference: "GMT+2:00"
                timeZonePathName: "Etc/GMT+2"
            }

            TimeZoneButton {
                id: buttonTimeZone_EAT
                timeZoneCode: "EAT"
                timeZoneName: "EASTERN AFRICAN TIME"
                timeZoneGMTReference: "GMT+3:00"
                timeZonePathName: "Etc/GMT+3"
            }

            TimeZoneButton {
                id: buttonTimeZone_MET
                timeZoneCode: "MET"
                timeZoneName: "MIDDLE EAST TIME"
                timeZoneGMTReference: "GMT+3:30"
                timeZonePathName: "Iran"
            }

            TimeZoneButton {
                id: buttonTimeZone_NET
                timeZoneCode: "NET"
                timeZoneName: "NEAR EAST TIME"
                timeZoneGMTReference: "GMT+4:00"
                timeZonePathName: "Etc/GMT+4"
            }

            // Asia
            TimeZoneLocationSeparator {
                region: "ASIA"
            }

            TimeZoneButton {
                id: buttonTimeZone_PLT
                timeZoneCode: "PLT"
                timeZoneName: "PAKISTAN LAHORE TIME"
                timeZoneGMTReference: "GMT+5:00"
                timeZonePathName: "Etc/GMT+5"
            }

            TimeZoneButton {
                id: buttonTimeZone_IST
                timeZoneCode: "IST"
                timeZoneName: "INDIA STANDARD TIME"
                timeZoneGMTReference: "GMT+5:30"
                timeZonePathName: "Asia/Calcutta"
            }

            TimeZoneButton {
                id: buttonTimeZone_BST
                timeZoneCode: "BST"
                timeZoneName: "BANGLADESH STANDARD TIME"
                timeZoneGMTReference: "GMT+6:00"
                timeZonePathName: "Etc/GMT+6"
            }

            TimeZoneButton {
                id: buttonTimeZone_VST
                timeZoneCode: "VST"
                timeZoneName: "VIETNAM STANDARD TIME"
                timeZoneGMTReference: "GMT+7:00"
                timeZonePathName: "Etc/GMT+7"
            }

            TimeZoneButton {
                id: buttonTimeZone_CTT
                timeZoneCode: "CTT"
                timeZoneName: "CHINA TAIWAN TIME"
                timeZoneGMTReference: "GMT+8:00"
                timeZonePathName: "Etc/GMT+8"
            }

            TimeZoneButton {
                id: buttonTimeZone_JST
                timeZoneCode: "JST"
                timeZoneName: "JAPAN STANDARD TIME"
                timeZoneGMTReference: "GMT+9:00"
                timeZonePathName: "Etc/GMT+9"
            }

            // Australia
            TimeZoneLocationSeparator {
                region: "AUSTRALIA"
            }

            TimeZoneButton {
                id: buttonTimeZone_ACT
                timeZoneCode: "ACT"
                timeZoneName: "AUSTRALIA CENTRAL TIME"
                timeZoneGMTReference: "GMT+9:30"
                timeZonePathName: "Australia/ACT"
            }

            TimeZoneButton {
                id: buttonTimeZone_AET
                timeZoneCode: "AET"
                timeZoneName: "AUSTRALIA EASTERN TIME"
                timeZoneGMTReference: "GMT+10:00"
                timeZonePathName: "Etc/GMT+10"
            }

            TimeZoneButton {
                id: buttonTimeZone_SST
                timeZoneCode: "SST"
                timeZoneName: "SOLOMON STANDARD TIME"
                timeZoneGMTReference: "GMT+11:00"
                timeZonePathName: "Etc/GMT+11"
            }

            TimeZoneButton {
                id: buttonTimeZone_NST
                timeZoneCode: "NST"
                timeZoneName: "NEW ZEALAND STANDARD TIME"
                timeZoneGMTReference: "GMT+12:00"
                timeZonePathName: "Etc/GMT+12"
            }

            TimeZoneButton {
                id: buttonTimeZone_MIT
                timeZoneCode: "MIT"
                timeZoneName: "MIDWAY ISLANDS TIME"
                timeZoneGMTReference: "GMT-11:00"
                timeZonePathName: "Etc/GMT-11"
            }
        }
    }
}
