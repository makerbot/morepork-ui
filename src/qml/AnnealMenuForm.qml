import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: annealSelect
    smooth: false
    anchors.fill: parent

    property alias annealSwipeView: annealSwipeView

    property alias annealPrint: annealPrint
    property alias annealPrintButton: annealPrintButton

    property alias annealMaterial: annealMaterial
    property alias annealMaterialButton: annealMaterialButton

    enum SwipeIndex {
        BasePage,                   //0
        AnnealPrint,                //1
        AnnealMaterial              //2
    }

    LoggingStackLayout {
        id: annealSwipeView
        logName: "annealSwipeView"
        currentIndex: AnnealMenu.BasePage

        // AnnealMenu.BasePage
        Item {
            id: annealBasePage
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Anneal")

            smooth: false

            FlickableMenu {
                id: annealButtons

                Column {
                    id: annealButtonsColumn
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: annealPrintButton
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: qsTr("ANNEAL PRINT")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: annealMaterialButton
                        buttonImage.source: "qrc:/img/icon_raise_lower_bp.png"
                        buttonText.text: qsTr("ANNEAL MATERIAL")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // AnnealMenu.AnnealPrintPage
        Item {
            id: annealPrintPage
            property var backSwiper: annealSwipeView
            property int backSwipeIndex: AnnealMenu.BasePage
            property string topBarTitle: qsTr("Anneal Print")
            property bool backIsCancel: bot.process.type == ProcessType.AnnealPrintProcess
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.AnnealPrintProcess) {
                    bot.cancel()
                    annealPrint.state = "cancelling"
                } else {
                    annealPrint.state = "base state"
                    annealSwipeView.swipeToItem(AnnealMenu.BasePage)
                }
            }

            AnnealPrint {
                id: annealPrint
            }
        }

        // AnnealMenu.AnnealMaterialPage
        Item {
            id: annealMaterialPage
            property var backSwiper: annealSwipeView
            property int backSwipeIndex: AnnealMenu.BasePage
            property string topBarTitle: qsTr("Anneal Material")
            property bool hasAltBack: true
            // (copypasted from SettingsPageForm)
            property bool backIsCancel: bot.process.type == ProcessType.DryingCycleProcess &&
                                        dryMaterial.state != "choose_material" &&
                                        dryMaterial.state != "custom_material" &&
                                        dryMaterial.state != "waiting_for_spool" &&
                                        dryMaterial.state != "dry_kit_instructions_2"
            smooth: false
            visible: false

            function altBack() {
                // (copypasted from SettingsPageForm)
                if(bot.process.type == ProcessType.DryingCycleProcess) {
                    if(dryMaterial.state == "choose_material") {
                        dryMaterial.state = "waiting_for_spool"
                        dryMaterial.doChooseMaterial = false
                    }
                    else if(dryMaterial.state == "custom_material")
                        dryMaterial.state = "choose_material"
                    else if(dryMaterial.state == "waiting_for_spool")
                        dryMaterial.state = "dry_kit_instructions_2"
                    else if(dryMaterial.state == "dry_kit_instructions_2")
                        dryMaterial.state = "dry_kit_instructions_1"
                    else
                        dryMaterial.cancelDryingCyclePopup.open()
                } else {
                    dryMaterial.state = "base state"
                    annealSwipeView.swipeToItem(AnnealMenu.BasePage)
                }
            }

            DryMaterial {
                id: annealMaterial
                doAnnealMaterial: true

                onProcessDone: {
                    state = "base state"
                    annealSwipeView.swipeToItem(AnnealMenu.BasePage)
                }
            }
        }
    }
}

