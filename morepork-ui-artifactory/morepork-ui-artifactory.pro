QT += core
QT -= gui
QT += network

CONFIG += c++11

TARGET = morepork-ui-artifactory
CONFIG += console
CONFIG -= app_bundle

LIBS += -L$$PWD/libarchiveqt/lib/libarchive/lib -larchive
LIBS += -L$$PWD/libarchiveqt/lib/liblzma/lib -llzma

INCLUDEPATH += $$PWD/libarchiveqt/lib/libarchive/include
DEPENDPATH += $$PWD/libarchiveqt/lib/libarchive/include

INCLUDEPATH += $$PWD/libarchiveqt/lib/liblzma/include
DEPENDPATH += $$PWD/libarchiveqt/lib/liblzma/include

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/libarchiveqt/lib/release/ -larchiveqt5
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/libarchiveqt/lib/debug/ -larchiveqt5
else:unix: LIBS += -L$$OUT_PWD/libarchiveqt/lib/ -larchiveqt5

INCLUDEPATH += $$PWD/libarchiveqt/lib
DEPENDPATH += $$PWD/libarchiveqt/lib


TEMPLATE = app

SOURCES += main.cpp \
    artifacts.cpp

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS += \
    artifacts.h
