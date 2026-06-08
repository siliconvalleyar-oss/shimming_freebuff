#!/bin/bash

echo "=== Arreglando y compilando shimming ==="

# Modificar shimming.pro
cat > shimming.pro << 'EOF'
QT       += core gui serialport
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
TARGET = shimming
TEMPLATE = app
SOURCES += main.cpp mainwindow.cpp fileshimming.cpp tableshimming.cpp rs232.cpp file.cpp
HEADERS  += mainwindow.h fileshimming.h tableshimming.h rs232.h file.h
FORMS    += mainwindow.ui
message("Qt version: $$[QT_VERSION]")
EOF

# Instalar QtSerialPort si falta
if [ ! -f /usr/lib/x86_64-linux-gnu/libQt5SerialPort.so ]; then
    echo "Instalando QtSerialPort..."
    sudo apt update
    sudo apt install -y libqt5serialport5-dev
fi

# Limpiar y compilar
echo "Limpiando archivos anteriores..."
make clean 2>/dev/null
rm -f Makefile .qmake.stash

echo "Ejecutando qmake..."
qmake

if [ $? -eq 0 ]; then
    echo "Compilando..."
    make -j$(nproc)
    
    if [ $? -eq 0 ]; then
        echo "✅ Compilación exitosa!"
        echo "Ejecutar: ./shimming"
        
        # Verificar si existe el ejecutable
        if [ -f ./shimming ]; then
            echo ""
            echo "Para ejecutar:"
            echo "  ./shimming"
            echo ""
            echo "Si tienes problemas con el puerto serie:"
            echo "  sudo chmod 666 /dev/ttyUSB0"
            echo "  # o agregar usuario al grupo dialout:"
            echo "  sudo usermod -a -G dialout $USER"
        fi
    else
        echo "❌ Error en make"
        exit 1
    fi
else
    echo "❌ Error en qmake"
    exit 1
fi

