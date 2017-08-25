TEMPLATE = app
TARGET = archiver

LIBS += -L$$PWD/../lib/libarchive/lib -larchive
LIBS += -L$$PWD/../lib/liblzma/lib -llzma

INCLUDEPATH += $$PWD/../lib/libarchive/include
DEPENDPATH += $$PWD/../lib/libarchive/include

INCLUDEPATH += $$PWD/../lib/liblzma/include
DEPENDPATH += $$PWD/../lib/liblzma/include

INCLUDEPATH += $$PWD/../lib/include
DEPENDPATH += $$PWD/../lib/include

SOURCES += example.cpp

CONFIG += silent warn_on
QT -= gui

MOC_DIR 	= ../build/moc
OBJECTS_DIR = ../build/obj
RCC_DIR		= ../build/qrc
UI_DIR      = ../build/uic

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../lib/release/ -larchiveqt5
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../lib/debug/ -larchiveqt5
else:unix: LIBS += -L$$OUT_PWD/../lib/ -larchiveqt5

INCLUDEPATH += $$PWD/../lib
DEPENDPATH += $$PWD/../lib
