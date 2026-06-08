#!/bin/bash

echo "=== Configurando dependencias para shimming ==="

# Buscar qextserialport
if [ -f /usr/include/qextserialport/qextserialport.h ]; then
    echo "✅ qextserialport encontrado en /usr/include"
    sed -i 's/include(\/usr\/local\/qextserialport\/src\/qextserialport.pri)/LIBS += -lqextserialport\nINCLUDEPATH += \/usr\/include\/qextserialport/' shimming.pro
    
elif [ -f /usr/local/include/qextserialport/qextserialport.h ]; then
    echo "✅ qextserialport encontrado en /usr/local/include"
    sed -i 's/include(\/usr\/local\/qextserialport\/src\/qextserialport.pri)/LIBS += -L\/usr\/local\/lib -lqextserialport\nINCLUDEPATH += \/usr\/local\/include\/qextserialport/' shimming.pro
    
elif pkg-config --exists qextserialport-qt5; then
    echo "✅ qextserialport encontrado via pkg-config"
    sed -i 's/include(\/usr\/local\/qextserialport\/src\/qextserialport.pri)/CONFIG += link_pkgconfig\nPKGCONFIG += qextserialport-qt5/' shimming.pro
    
else
    echo "❌ qextserialport no encontrado. Instalando..."
    cd /tmp
    git clone https://github.com/qextserialport/qextserialport.git
    cd qextserialport
    qmake
    make
    sudo make install
    
    echo "✅ Instalación completada"
    echo "Actualizando shimming.pro..."
    sed -i 's/include(\/usr\/local\/qextserialport\/src\/qextserialport.pri)/LIBS += -L\/usr\/local\/lib -lqextserialport\nINCLUDEPATH += \/usr\/local\/include\/qextserialport/' ../shimming.pro
    cd ..
fi

echo "=== Limpiando y reconfigurando ==="
make clean
rm -f Makefile
qmake

echo "=== Compilando ==="
make

echo "=== Listo ==="
echo "Ejecutar: ./shimming"

