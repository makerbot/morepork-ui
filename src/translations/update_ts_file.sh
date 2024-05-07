#!/bin/bash

# 'lupdate' refers to the symlink in /usr/bin/ which points to 'qtchooser' which
# is responsible for opening Qt tools like lupdate, lrelease etc. pertaining
# to the correct version of Qt in case multiple versions are installed.
# The version to use while launching a Qt tool can be passed to qtchooser but
# it is non persistent and reverts to 'qt-default'.
# To set Qt to open Qt5 binaries by default edit the config for 'qt-default'
# at '/usr/lib/x86_64-linux-gnu/qt-default/qtchooser/default.conf' for linux
# to point to qt5 binary and library folders.
# (or)
# Edit this script to pass in the absolute 'lupdate' path for qt5 otherwise
# the qt4 version will be used by default by 'qtchooser'

/home/praveen/Qt/5.12.5/gcc_64/bin/lupdate -no-obsolete ../qml/*.qml -ts \
translation_ar_EG.ts \
translation_zh_CN.ts \
translation_nl_NL.ts \
translation_en_US.ts \
translation_fr_FR.ts \
translation_de_DE.ts \
translation_it_IT.ts \
translation_ja_JP.ts \
translation_ko_KR.ts \
translation_es_ES.ts \
