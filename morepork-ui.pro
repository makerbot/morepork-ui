TEMPLATE = app

QT += qml quick
CONFIG += c++11

include(src/src.pri)

RESOURCES += ui/ui.qrc host/host.qrc

# Stuff we only build for qt creator builds
include(host/host.pri)

# Disable all APIs deprecated before Qt 6.0.0
# TODO: Add this to CMake
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000

# This should only be defined in the Qt creator build to handle things
# that legitimately need to be different there.
DEFINES += MOREPORK_UI_QT_CREATOR_BUILD

# Note that if you find youself needing to add things here to get
# something to work in qt creator, you are probably also going to
# need to edit the CMakeLists...
