#!/bin/bash

# lrelease and lupdate are linguist tools provided by Qt, the binaries for which
# are in the Qt install directory. They are also in the 'Install' directory in our
# toolchain which is pretty convenient as it allows us to provide a relative path
# and expect it to work consistently across machines assuming that everyone has the
# the default folder structure for our toolchain. Otherwise, edit the path below
# when you run this script.

../../../../Install/bin/lupdate ../qml/*.qml -ts \
translation_ar_EG.ts \
translation_zh_CN.ts \
translation_en_GB.ts \
translation_fr_FR.ts \
translation_de_DE.ts \
translation_it_IT.ts \
translation_ja_JP.ts \
translation_ko_KR.ts \
translation_ru_RU.ts \
translation_es_ES.ts \
