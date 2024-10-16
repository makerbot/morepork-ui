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
                        buttonImage.source: "qrc:/img/icon_anneal_print.png"
                        buttonText.text: qsTr("ANNEAL PRINT")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: annealMaterialButton
                        buttonImage.source: "qrc:/img/icon_material.png"
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
            property bool backIsCancel: bot.process.type == ProcessType.AnnealPrintProcess &&
                                        bot.process.isProcessCancellable
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.AnnealPrintProcess &&
                        bot.process.isProcessCancellable) {
                    cancelPopup.openPopup(()=> {
                        annealPrint.state = 'cancelling'
                        bot.cancel()
                    })
                } else {
                    annealPrint.state = "base state"
                    annealSwipeView.swipeToItem(AnnealMenu.BasePage)
                }
            }

            AnnealPrint {
                id: annealPrint

                onProcessDone: {
                    state = "base state"
                    annealSwipeView.swipeToItem(AnnealMenu.BasePage)
                }
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
                                        annealMaterial.state != "choose_material" &&
                                        annealMaterial.state != "custom_material" &&
                                        annealMaterial.state != "waiting_for_spool" &&
                                        annealMaterial.state != "dry_kit_instructions_2"
            smooth: false
            visible: false

            function altBack() {
                // (copypasted from SettingsPageForm)
                if(bot.process.type == ProcessType.DryingCycleProcess) {
                    if(annealMaterial.state == "choose_material") {
                        annealMaterial.state = "waiting_for_spool"
                        annealMaterial.doChooseMaterial = false
                    }
                    else if(annealMaterial.state == "custom_material")
                        annealMaterial.state = "choose_material"
                    else if(annealMaterial.state == "waiting_for_spool")
                        annealMaterial.state = "dry_kit_instructions_2"
                    else if(annealMaterial.state == "dry_kit_instructions_2")
                        annealMaterial.state = "dry_kit_instructions_1"
                    else
                        cancelPopup.openPopup(()=> {
                            annealMaterial.state = 'cancelling'
                            bot.cancel()
                        })
                } else {
                    annealMaterial.state = "base state"
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

