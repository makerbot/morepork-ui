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
                region: qsTr("AMERICAS")
            }

            TimeZoneButton {
                id: buttonTimeZone_HST
                timeZoneCode: qsTr("HST")
                timeZoneName: qsTr("HAWAII STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-10:00")
                timeZonePathName: "US/Hawaii"
            }

            TimeZoneButton {
                id: buttonTimeZone_AST
                timeZoneCode: qsTr("AST")
                timeZoneName: qsTr("ALASKA STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-9:00")
                timeZonePathName: "US/Alaska"
            }

            TimeZoneButton {
                id: buttonTimeZone_PST
                timeZoneCode: qsTr("PST")
                timeZoneName: qsTr("PACIFIC STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-8:00")
                timeZonePathName: "US/Pacific"
            }

            TimeZoneButton {
                id: buttonTimeZone_PNT
                timeZoneCode: qsTr("PNT")
                timeZoneName: qsTr("PHOENIX STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-7:00")
                timeZonePathName: "US/Arizona"
            }

            TimeZoneButton {
                id: buttonTimeZone_MST
                timeZoneCode: qsTr("MST")
                timeZoneName: qsTr("MOUNTAIN STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-7:00")
                timeZonePathName: "US/Mountain"
            }

            TimeZoneButton {
                id: buttonTimeZone_CST
                timeZoneCode: qsTr("CST")
                timeZoneName: qsTr("CENTRAL STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-6:00")
                timeZonePathName: "US/Central"
            }

            TimeZoneButton {
                id: buttonTimeZone_EST
                timeZoneCode: qsTr("EST")
                timeZoneName: qsTr("EASTERN STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-5:00")
                timeZonePathName: "US/Eastern"
            }

            TimeZoneButton {
                id: buttonTimeZone_IET
                timeZoneCode: qsTr("IET")
                timeZoneName: qsTr("INDIANA EASTERN STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-5:00")
                timeZonePathName: "US/East-Indiana"
            }

            TimeZoneButton {
                id: buttonTimeZone_PRT
                timeZoneCode: qsTr("PRT")
                timeZoneName: qsTr("PUERTO RICO & US VIRGIN ISLANDS TIME")
                timeZoneGMTReference: qsTr("GMT-4:00")
                timeZonePathName: "Etc/GMT-4"
            }

            TimeZoneButton {
                id: buttonTimeZone_CNT
                timeZoneCode: qsTr("CNT")
                timeZoneName: qsTr("CANADA NEWFOUNDLAND TIME")
                timeZoneGMTReference: qsTr("GMT-3:30")
                timeZonePathName: "Canada/Newfoundland"
            }

            TimeZoneButton {
                id: buttonTimeZone_AGT
                timeZoneCode: qsTr("AGT")
                timeZoneName: qsTr("ARGENTINA STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT-3:00")
                timeZonePathName: "Etc/GMT-3"
            }

            TimeZoneButton {
                id: buttonTimeZone_BET
                timeZoneCode: qsTr("BET")
                timeZoneName: qsTr("BRAZIL EASTERN TIME")
                timeZoneGMTReference: qsTr("GMT-3:00")
                timeZonePathName: "Etc/GMT-3"
            }

            // Europe
            TimeZoneLocationSeparator {
                region: qsTr("EUROPE")
            }

            TimeZoneButton {
                id: buttonTimeZone_CAT
                timeZoneCode: qsTr("CAT")
                timeZoneName: qsTr("CENTRAL AFRICAN TIME")
                timeZoneGMTReference: qsTr("GMT-1:00")
                timeZonePathName: "Etc/GMT-1"
            }

            TimeZoneButton {
                id: buttonTimeZone_GMT
                timeZoneCode: qsTr("GMT")
                timeZoneName: qsTr("GREENWICH MEAN TIME")
                timeZoneGMTReference: qsTr("GMT")
                timeZonePathName: "UTC"
            }

            TimeZoneButton {
                id: buttonTimeZone_ECT
                timeZoneCode: qsTr("ECT")
                timeZoneName: qsTr("EUROPEAN CENTRAL TIME")
                timeZoneGMTReference: qsTr("GMT+1:00")
                timeZonePathName: "Etc/GMT+1"
            }

            TimeZoneButton {
                id: buttonTimeZone_EET
                timeZoneCode: qsTr("EET")
                timeZoneName: qsTr("EASTERN EUROPEAN TIME")
                timeZoneGMTReference: qsTr("GMT+2:00")
                timeZonePathName: "Etc/GMT+2"
            }

            // Middle East
            TimeZoneLocationSeparator {
                region: qsTr("MIDDLE EAST")
            }

            TimeZoneButton {
                id: buttonTimeZone_ART
                timeZoneCode: qsTr("ART")
                timeZoneName: qsTr("(ARABIC) EGYPT STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+2:00")
                timeZonePathName: "Etc/GMT+2"
            }

            TimeZoneButton {
                id: buttonTimeZone_EAT
                timeZoneCode: qsTr("EAT")
                timeZoneName: qsTr("EASTERN AFRICAN TIME")
                timeZoneGMTReference: qsTr("GMT+3:00")
                timeZonePathName: "Etc/GMT+3"
            }

            TimeZoneButton {
                id: buttonTimeZone_MET
                timeZoneCode: qsTr("MET")
                timeZoneName: qsTr("MIDDLE EAST TIME")
                timeZoneGMTReference: qsTr("GMT+3:30")
                timeZonePathName: "Iran"
            }

            TimeZoneButton {
                id: buttonTimeZone_NET
                timeZoneCode: qsTr("NET")
                timeZoneName: qsTr("NEAR EAST TIME")
                timeZoneGMTReference: qsTr("GMT+4:00")
                timeZonePathName: "Etc/GMT+4"
            }

            // Asia
            TimeZoneLocationSeparator {
                region: qsTr("ASIA")
            }

            TimeZoneButton {
                id: buttonTimeZone_PLT
                timeZoneCode: qsTr("PLT")
                timeZoneName: qsTr("PAKISTAN LAHORE TIME")
                timeZoneGMTReference: qsTr("GMT+5:00")
                timeZonePathName: "Etc/GMT+5"
            }

            TimeZoneButton {
                id: buttonTimeZone_IST
                timeZoneCode: qsTr("IST")
                timeZoneName: qsTr("INDIA STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+5:30")
                timeZonePathName: "Asia/Calcutta"
            }

            TimeZoneButton {
                id: buttonTimeZone_BST
                timeZoneCode: qsTr("BST")
                timeZoneName: qsTr("BANGLADESH STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+6:00")
                timeZonePathName: "Etc/GMT+6"
            }

            TimeZoneButton {
                id: buttonTimeZone_VST
                timeZoneCode: qsTr("VST")
                timeZoneName: qsTr("VIETNAM STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+7:00")
                timeZonePathName: "Etc/GMT+7"
            }

            TimeZoneButton {
                id: buttonTimeZone_CHN
                timeZoneCode: qsTr("CHN")
                timeZoneName: qsTr("CHINA STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+8:00")
                timeZonePathName: "Etc/GMT+8"
            }

            TimeZoneButton {
                id: buttonTimeZone_JST
                timeZoneCode: qsTr("JST")
                timeZoneName: qsTr("JAPAN STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+9:00")
                timeZonePathName: "Etc/GMT+9"
            }

            // Australia
            TimeZoneLocationSeparator {
                region: qsTr("AUSTRALIA")
            }

            TimeZoneButton {
                id: buttonTimeZone_ACT
                timeZoneCode: qsTr("ACT")
                timeZoneName: qsTr("AUSTRALIA CENTRAL TIME")
                timeZoneGMTReference: qsTr("GMT+9:30")
                timeZonePathName: "Australia/ACT"
            }

            TimeZoneButton {
                id: buttonTimeZone_AET
                timeZoneCode: qsTr("AET")
                timeZoneName: qsTr("AUSTRALIA EASTERN TIME")
                timeZoneGMTReference: qsTr("GMT+10:00")
                timeZonePathName: "Etc/GMT+10"
            }

            TimeZoneButton {
                id: buttonTimeZone_SST
                timeZoneCode: qsTr("SST")
                timeZoneName: qsTr("SOLOMON STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+11:00")
                timeZonePathName: "Etc/GMT+11"
            }

            TimeZoneButton {
                id: buttonTimeZone_NST
                timeZoneCode: qsTr("NST")
                timeZoneName: qsTr("NEW ZEALAND STANDARD TIME")
                timeZoneGMTReference: qsTr("GMT+12:00")
                timeZonePathName: "Etc/GMT+12"
            }

            TimeZoneButton {
                id: buttonTimeZone_MIT
                timeZoneCode: qsTr("MIT")
                timeZoneName: qsTr("MIDWAY ISLANDS TIME")
                timeZoneGMTReference: qsTr("GMT-11:00")
                timeZonePathName: "Etc/GMT-11"
            }
        }
    }
}
