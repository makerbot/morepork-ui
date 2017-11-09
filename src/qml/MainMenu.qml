import QtQuick 2.7

MainMenuForm {
    id: mainMenu

    signal openPrintPage
    signal openExtruderPage
    signal openSettingsPage
    signal openInfoPage
    signal openMaterialPage
    signal openPreheatPage

    mainMenuIcon_print
    {
        textIconDesc.text: qsTr("PRINT") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openPrintPage()
    }

    mainMenuIcon_extruder
    {
        textIconDesc.text: qsTr("EXTRUDER") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openExtruderPage()
    }

    mainMenuIcon_settings
    {
        textIconDesc.text: qsTr("SETTINGS") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openSettingsPage()
    }

    mainMenuIcon_info
    {
        textIconDesc.text: qsTr("INFO") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openInfoPage()
    }
    mainMenuIcon_material
    {
        textIconDesc.text: qsTr("MATERIAL") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openMaterialPage()
    }

    mainMenuIcon_preheat
    {
        textIconDesc.text: qsTr("PREHEAT") + cpUiTr.emptyStr
        mouseArea.onClicked: mainMenu.openPreheatPage()
    }
}

