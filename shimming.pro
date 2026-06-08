#-------------------------------------------------
# Project created for Shimming Application
#-------------------------------------------------

QT       += core gui serialport widgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = shimming
TEMPLATE = app

# Directorios
INCLUDEPATH += include
VPATH += src

# Directorio para archivos objeto
OBJECTS_DIR = obj
MOC_DIR = obj/moc
RCC_DIR = obj/rcc
UI_DIR = obj/ui

# Archivos fuente
SOURCES += \
    src/main.cpp \
    src/mainwindow.cpp \
    src/fileshimming.cpp \
    src/tableshimming.cpp \
    src/rs232.cpp \
    src/file.cpp

# Archivos de cabecera
HEADERS += \
    include/mainwindow.h \
    include/fileshimming.h \
    include/tableshimming.h \
    include/rs232.h \
    include/file.h \
    include/config.h

# Archivos de formulario
FORMS += src/mainwindow.ui

# Directorio de salida
DESTDIR = bin

# Opciones de compilación
CONFIG += release
CONFIG -= debug

# Definir directorios para logs y plots
DEFINES += LOG_DIR=\\\"$$PWD/logs/\\\"
DEFINES += PLOTS_DIR=\\\"$$PWD/plots/\\\"

# Mensaje de información
message("Shimming project configured with src/, include/, obj/ structure")
message("Logs directory: $$PWD/logs")
message("Plots directory: $$PWD/plots")
message("Objects directory: $$PWD/obj")
