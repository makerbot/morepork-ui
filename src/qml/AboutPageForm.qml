import QtQml 2.8
import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.9

Item {
    id: itemAboutPage
    smooth: false
    anchors.fill: parent

    property variant packages: [
        {name:"avahi", version:"0.7", licenses:"LGPL-2.1", url:"https://github.com/avahi/avahi"},
        {name:"boost", version:"1.72.0", licenses:"Boost Software License, Version 1.0", url:"https://github.com/boostorg/boost"},
        {name:"busybox", version:"1.31.1", licenses:"GPL-2", url: "https://git.busybox.net/busybox/"},
        {name:"build-root", version:"2020.02.1", licenses:"GPL-2", url:"https://github.com/makerbot/mb-build-root"},
        {name:"connman", version:"1.37", licenses:"GPL-2", url:"https://git.kernel.org/pub/scm/network/connman/connman.git"},
        {name:"crda", version:"4.14", licenses:"copyleft-next-0.3.0", url:"https://github.com/mcgrof/crda"},
        {name:"dbus", version:"1.12.16", licenses:"GPL-2", url:"https://gitlab.freedesktop.org/dbus/dbus/"},
        {name:"dbus-python", version:"1.2.12", url:"https://gitlab.freedesktop.org/dbus/dbus-python/"},
        {name:"dfu-util", version:"0.8", licenses:"GPL-2", url:"https://sourceforge.net/p/dfu-util/dfu-util/ci/master/tree/"},
        {name:"e2fsprogs", version:"1.45.5", licenses:"LGPL-2, GPL-2", url:"https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"},
        {name:"ethtool", version:"5.4", licenses:"GPL-2", url:"https://git.kernel.org/pub/scm/network/ethtool/ethtool.git"},
        {name:"expat", version:"2.2.9", url:"https://github.com/libexpat/libexpat"},
        {name:"freetype", version:"2.10.1", licenses:"GPL-2", url:"https://github.com/freetype/freetype"},
        {name:"gdb", version:"8.2.1", licenses:"GPL-2", url:"https://sourceware.org/git/binutils-gdb.git"},
        {name:"gnupg", version:"1.4.23", licenses:"GPL-3", url:"https://github.com/gpg/gnupg"},
        {name:"iptables", version:"1.8.3", licenses:"GPL-2", url:"https://git.netfilter.org/iptables/"},
        {name:"iw", version:"5.3", licenses:"ISC", url:"https://git.sipsolutions.net/iw.git"},
        {name:"jimtcl", version:"0.79", licenses:"BSD", url:"https://github.com/msteveb/jimtcl"},
        {name:"jpeg-turbo", version:"2.0.4", licenses:"BSD", url:"https://github.com/libjpeg-turbo/libjpeg-turbo"},
        {name:"json-cpp", version:"2.0.4", licenses:"MIT", url:"https://github.com/makerbot/json-cpp"},
        {name:"jsonrpc", url:"https://github.com/makerbot/jsonrpc"},
        {name:"kmod", version:"26", licenses:"LGPL-2.1", url:"https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git"},
        {name:"libcap", version:"2.27", licenses:"MIT, GPL-2", url:"https://git.kernel.org/pub/scm/libs/libcap/libcap.git"},
        {name:"libdaemon", version:"0.14", licenses:"LGPL-2.1", url:"https://git.0pointer.net/libdaemon.git"},
        {name:"libffi", version:"3.3", url:"https://github.com/libffi/libffi"},
        {name:"libgcrypt", version:"1.8.5", licenses:"LGPL-2.1", url:"https://github.com/gpg/libgcrypt"},
        {name:"libglib2", version:"2.62.4", licenses:"LGPL-2.1", url:"https://gitlab.gnome.org/GNOME/glib"},
        {name:"libgpg-error", version:"1.37", licenses:"LGPL-2.1", url:"https://github.com/gpg/libgpg-error"},
        {name:"liblockfile", version:"1.09", licenses:"LGPL-2", url:"https://github.com/miquels/liblockfile"},
        {name:"libnl", version:"3.5.0", licenses:"LGPL-2.1, GPL-2", url:"https://github.com/thom311/libnl"},
        {name:"libopenssl", version:"1.1.1f", url:"https://github.com/openssl/openssl"},
        {name:"libpng", version:"1.6.37", url:"https://github.com/pnggroup/libpng"},
        {name:"libusb", version:"1.0.23", licenses:"LGPL-2.1", url:"https://github.com/libusb/libusb"},
        {name:"libzlib", version:"1.2.11"},
        {name:"linux", version:"4.1.18", licenses:"GPL-2", url:"https://github.com/makerbot/linux-Birdwing"},
        {name:"lockfile-progs", version:"0.1.18"},
        {name:"mii-diag", version:"2.11"},
        {name:"morepork-ui", version:"2.7", licenses: "GPL-3", url:"https://github.com/makerbot/morepork-ui"},
        {name:"nano", version:"4.7", licenses: "GPL-3, BSD", url:"https://git.savannah.gnu.org/cgit/nano.git"},
        {name:"nanopb", version:"0.3.6", licenses: "ZLIB"},
        {name:"ncurses", version:"6.1", licenses: "MIT"},
        {name:"openssh", version:"8.1p1", licenses: "BSD", url:"https://github.com/openssh/openssh-portable"},
        {name:"pcre2", version:"10.33", licenses: "BSD"},
        {name:"pcre", version:"8.43", licenses: "BSD"},
        {name:"popt", version:"1.16", licenses: "X11"},
        {name:"python3", version:"3.8.2", licenses: "PSF", url:"https://github.com/python/cpython"},
        {name:"qt", version:"5.12.7", licenses: "LGPL-3, GPL-3", url:"https://github.com/Ultimaker/qt5"},
        {name:"readline", version:"8.0", licenses:"GPL-3", url:"https://git.savannah.gnu.org/cgit/readline.git"},
        {name:"rsync", version:"3.1.3", licenses:"GPL-3", url:"https://github.com/RsyncProject/rsync"},
        {name:"sl", version:"5.02"},
        {name:"strace", version:"5.4", licenses:"LGPL-2.1", url:"https://github.com/strace/strace"},
        {name:"systemd", version:"244.3", url:"https://github.com/systemd/systemd"},
        {name:"tzdata", version:"2019c"},
        {name:"u-boot", licenses:"GPL-2", url:"https://github.com/makerbot/u-boot"},
        {name:"uemacs", url:"https://git.kernel.org/pub/scm/editors/uemacs/uemacs.git"},
        {name:"usb_modeswitch_data", version:"20191128"},
        {name:"usb_modeswitch", version:"2.6.0", licenses:"GPL-2", url:"https://www.draisberghof.de/usb_modeswitch/"},
        {name:"usbmount", version:"0.0.22", licenses:"BSD", url:"https://github.com/rbrito/usbmount"},
        {name:"util-linux", version:"2.35.1", licenses:"GPL-2", url:"https://github.com/util-linux/util-linux"},
        {name:"vim", version:"8.1.1929", url:"https://github.com/vim/vim"},
        {name:"wireless-regdb", version:"2019.06.03", licenses:"ISC"},
        {name:"wpa_supplicant", version:"2.9", licenses:"BSD"},
        {name:"yajl", version:"2.1.0", licenses:"ISC"},
        {name:"zlib", version:"1.2.5", licenses:"ZLIB"},
    ]

    property string selectedPackageName: ""
    property string selectedPackageVersion: ""
    property string selectedPackageLicenses: ""
    property string selectedPackageURL: ""

    enum SwipeIndex {
        ListPackages,
        PackageDetails
    }

    LoggingStackLayout {
        id: aboutSwipeView
        logName: "aboutSwipeView"
        currentIndex: AboutPage.ListPackages

        // AboutPage.ListPackages
        Item {
            id: itemListPackages
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: false
            smooth: false
            visible: true

            ListSelector {
                id: packagesList
                model: packages
                header:
                    TextBody {
                        Layout.alignment: Qt.AlignHCenter
                        width: 720
                        x: 40
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: qsTr("This printer is developed by Ultimaker and proudly incorporates components licenced under various open-source licences, including GNU General Public Licence v3 (GPLv3) and GNU Lesser General Public Licence v3 (LGPLv3). The licence information for each component, and source code, where applicable, is available for each package listed below.")
                    }
                delegate:
                    MenuButton {
                        id: packageButton
                        enabled: true
                        buttonText.text: model.modelData.name

                        onClicked: {
                            selectedPackageName = model.modelData.name;
                            selectedPackageVersion = model.modelData.version || "" ;
                            selectedPackageLicenses = model.modelData.licenses || "";
                            selectedPackageURL = model.modelData.url || "";

                            aboutSwipeView.swipeToItem(AboutPage.PackageDetails);
                        }
                    }
            }
        }

        // AboutPage.PackageDetails
        Item {
            id: itemPackageDetails
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: aboutSwipeView
            property int backSwipeIndex: AboutPage.ListPackages
            property bool hasAltBack: false
            smooth: false
            visible: false

            ColumnLayout {
                id: packageDetailsLayout
                width: 800
                height: 350
                smooth: false
                spacing: 20
                anchors.fill: parent
                anchors.leftMargin: 60
                anchors.topMargin: 37

                TextHeadline {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: selectedPackageName
                }
                InfoItem {
                    id: info_packageVersion
                    labelText: qsTr("Version")
                    visible: selectedPackageVersion != ""
                    dataText: selectedPackageVersion
                }
                InfoItem {
                    id: info_packageLicenses
                    labelText: qsTr("Licenses")
                    visible: selectedPackageLicenses != ""
                    dataText: selectedPackageLicenses
                }
                TextBody {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: selectedPackageURL? qsTr("Source code available at:") + "<br><br>" + selectedPackageURL : ""
                }
            }
        }
    }
}
