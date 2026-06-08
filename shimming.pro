QT       += core gui serialport printsupport
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
TARGET = shimming
TEMPLATE = app

DESTDIR = bin
OBJECTS_DIR = obj

SOURCES += \
    src/main.cpp \
    src/mainwindow.cpp \
    src/fileshimming.cpp \
    src/tableshimming.cpp \
    src/rs232.cpp \
    src/file.cpp

HEADERS += \
    include/mainwindow.hpp \
    include/fileshimming.hpp \
    include/tableshimming.hpp \
    include/rs232.hpp \
    include/file.hpp \
    include/config.hpp

FORMS += src/mainwindow.ui

INCLUDEPATH += include

message("Qt version: $$[QT_VERSION]")
