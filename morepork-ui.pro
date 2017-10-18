TEMPLATE = app

QT += core quick multimedia
CONFIG += c++11

include(src/src.pri)

RESOURCES = src/qml/qml.qrc \
            src/qml/media.qrc

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

# Comment the line below to enable qDebug() console output
# when building in Release mode.
#DEFINES += QT_NO_DEBUG_OUTPUT

DEFINES += MOREPORK_ROOT_DIR=\\\"$$_PRO_FILE_PWD_\\\"

DISTFILES +=
