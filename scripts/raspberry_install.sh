#!/bin/bash

# Script para adaptar el proyecto shimming a Raspberry Pi 4
# Con pantalla oficial LCD 800x480

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Adaptando a Raspberry Pi 4${NC}"
echo -e "${BLUE}========================================${NC}"

# ==================== DETECTAR ARQUITECTURA ====================
if [[ $(uname -m) == "aarch64" ]] || [[ $(uname -m) == "armv7l" ]]; then
    echo -e "${GREEN}✅ Detectado: Raspberry Pi (ARM)${NC}"
else
    echo -e "${YELLOW}⚠️  No es ARM, pero igual se aplicarán configuraciones${NC}"
fi

# ==================== INSTALAR DEPENDENCIAS ====================
echo -e "${BLUE}Instalando dependencias para Raspberry Pi...${NC}"

sudo apt update
sudo apt install -y \
    qt5-default \
    qtbase5-dev \
    qtbase5-dev-tools \
    qt5-qmake \
    libqt5serialport5 \
    libqt5serialport5-dev \
    libqt5svg5 \
    libqt5svg5-dev \
    libqt5multimedia5 \
    libqt5multimedia5-plugins \
    libqt5multimediawidgets5 \
    libqt5multimedia5-dev \
    libqt5eglfsdeviceintegration5 \
    libqt5libqeglfsdeviceintegration5

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

# ==================== CONFIGURAR PANTALLA 800x480 ====================
echo -e "${BLUE}Configurando pantalla LCD oficial 800x480...${NC}"

# Crear archivo de configuración para Qt en Raspberry Pi
cat > qt_env.sh << 'EOF'
#!/bin/bash

# Configuración de entorno Qt para Raspberry Pi 4 con pantalla LCD oficial

# Usar EGLFS para gráficos acelerados
export QT_QPA_PLATFORM=eglfs

# Configuración de pantalla 800x480
export QT_QPA_EGLFS_WIDTH=800
export QT_QPA_EGLFS_HEIGHT=480

# Deshabilitar cursor (opcional)
export QT_QPA_EGLFS_HIDECURSOR=1

# Configuración de framebuffer
export QT_QPA_FB_DRM=1

# Para pantalla táctil
export QT_QPA_EGLFS_TSLIB=1
export TSLIB_TSDEVICE=/dev/input/touchscreen

# Evitar problemas de memoria
export QT_QPA_FONTDIR=/usr/share/fonts/truetype/dejavu
export QT_LOGGING_RULES="qt.qpa.*=false"

echo "Entorno Qt configurado para pantalla 800x480"
EOF

chmod +x qt_env.sh

# ==================== MODIFICAR main.cpp PARA PANTALLA TÁCTIL ====================
echo -e "${BLUE}Modificando main.cpp para pantalla táctil...${NC}"

# Crear backup
cp src/main.cpp src/main.cpp.bak

cat > src/main.cpp << 'EOF'
#include "mainwindow.h"
#include <QApplication>
#include <QSplashScreen>
#include <QTimer>
#include <QDebug>
#include <QIcon>
#include <QPixmap>
#include <QDir>
#include <QFile>
#include <QScreen>
#include <QStyleFactory>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    
    // Configuración para Raspberry Pi con pantalla táctil
    #ifdef Q_OS_LINUX
    // Usar estilo Fusion que funciona bien en táctil
    a.setStyle(QStyleFactory::create("Fusion"));
    
    // Aumentar el tamaño de los iconos y elementos táctiles
    QPalette palette;
    palette.setColor(QPalette::Window, Qt::white);
    a.setPalette(palette);
    #endif
    
    // Crear directorios necesarios
    QDir dir;
    dir.mkpath("icons");
    dir.mkpath("logs");
    dir.mkpath("plots");
    
    QSplashScreen splash;
    QString splashPath = QDir::currentPath() + "/icons/animal.png";
    if (QFile::exists(splashPath)) {
        splash.setPixmap(QPixmap(splashPath));
    } else {
        QPixmap pixmap(400, 240);
        pixmap.fill(Qt::white);
        splash.setPixmap(pixmap);
        splash.showMessage("Cargando Shimming...", Qt::AlignCenter, Qt::darkBlue);
    }
    splash.setWindowOpacity(0.95);
    splash.show();
    QTimer::singleShot(800, &splash, &QSplashScreen::close);
    
    MainWindow w;
    
    // Configurar ventana para pantalla 800x480
    w.setWindowState(Qt::WindowMaximized);
    
    // Aplicar estilo táctil (botones más grandes)
    QString styleSheet = R"(
        QPushButton {
            font-size: 14px;
            padding: 10px;
            min-height: 40px;
            min-width: 100px;
            border-radius: 5px;
            background-color: #4CAF50;
            color: white;
        }
        QPushButton:hover {
            background-color: #45a049;
        }
        QPushButton:pressed {
            background-color: #3d8b40;
        }
        QLineEdit {
            font-size: 16px;
            padding: 8px;
            min-height: 35px;
            border: 2px solid #ccc;
            border-radius: 5px;
        }
        QPlainTextEdit {
            font-size: 12px;
            font-family: monospace;
        }
        QTabWidget::pane {
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        QTabBar::tab {
            font-size: 14px;
            padding: 8px 20px;
            min-width: 80px;
        }
        QLabel {
            font-size: 14px;
        }
    )";
    w.setStyleSheet(styleSheet);
    
    QString iconPath = QDir::currentPath() + "/icons/icon.png";
    if (QFile::exists(iconPath))
        w.setWindowIcon(QIcon(iconPath));
    
    w.show();
    
    return a.exec();
}
EOF

echo -e "${GREEN}✅ main.cpp modificado para pantalla táctil${NC}"

# ==================== MODIFICAR MAINWINDOW.UI PARA TÁCTIL ====================
echo -e "${BLUE}Mejorando interfaz para pantalla táctil 800x480...${NC}"

# Backup del ui original
cp src/mainwindow.ui src/mainwindow.ui.bak

# Usar sed para modificar el archivo UI (mejorar tamaños)
# Aumentar tamaño de botones y fuentes
sed -i 's/min-width: 101px/min-width: 120px/g' src/mainwindow.ui
sed -i 's/min-height: 61px/min-height: 70px/g' src/mainwindow.ui
sed -i 's/pointsize>6/pointsize>10/g' src/mainwindow.ui
sed -i 's/pointsize>11/pointsize>14/g' src/mainwindow.ui
sed -i 's/pointsize>16/pointsize>18/g' src/mainwindow.ui

echo -e "${GREEN}✅ UI optimizada para pantalla táctil${NC}"

# ==================== AGREGAR SOPORTE GPIO ====================
echo -e "${BLUE}Agregando soporte para GPIO (opcional)...${NC}"

# Instalar librería WiringPi para GPIO
if ! command -v gpio &> /dev/null; then
    echo -e "${YELLOW}Instalando WiringPi para GPIO...${NC}"
    cd /tmp
    git clone https://github.com/WiringPi/WiringPi.git
    cd WiringPi
    ./build
    cd ..
    rm -rf WiringPi
    echo -e "${GREEN}✅ WiringPi instalado${NC}"
fi

# ==================== CREAR SCRIPT DE INICIO AUTOMÁTICO ====================
echo -e "${BLUE}Creando script de inicio automático...${NC}"

cat > run_shimming.sh << 'EOF'
#!/bin/bash

# Script para ejecutar shimming en Raspberry Pi
# Para inicio automático agregar al rc.local o .bashrc

cd /home/pi/shimming  # Cambiar por la ruta correcta

# Cargar configuración de pantalla
source qt_env.sh

# Ejecutar aplicación
./bin/shimming

# Si falla, usar plataforma X11
if [ $? -ne 0 ]; then
    echo "Falló EGLFS, usando X11..."
    export QT_QPA_PLATFORM=xcb
    ./bin/shimming
fi
EOF

chmod +x run_shimming.sh

# ==================== CREAR SERVICIO SYSTEMD ====================
echo -e "${BLUE}Creando servicio systemd para inicio automático...${NC}"

sudo cat > /etc/systemd/system/shimming.service << 'EOF'
[Unit]
Description=Shimming Application
After=multi-user.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/shimming
Environment="QT_QPA_PLATFORM=eglfs"
Environment="QT_QPA_EGLFS_WIDTH=800"
Environment="QT_QPA_EGLFS_HEIGHT=480"
ExecStart=/home/pi/shimming/run_shimming.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# ==================== MODIFICAR shimming.pro PARA RASPBERRY ====================
echo -e "${BLUE}Actualizando shimming.pro para Raspberry Pi...${NC}"

# Agregar configuración específica para Raspberry
cat >> shimming.pro << 'EOF'

# Configuración específica para Raspberry Pi
raspberry {
    DEFINES += RASPBERRY_PI
    LIBS += -lwiringPi  # Para GPIO
    QMAKE_CXXFLAGS += -march=armv8-a -mtune=cortex-a72
}

# Detectar Raspberry Pi automáticamente
linux-g++ {
    contains(QMAKE_HOST.arch, arm.*) {
        message("Configurando para Raspberry Pi ARM")
        DEFINES += RASPBERRY_PI
        LIBS += -lwiringPi
    }
}
EOF

echo -e "${GREEN}✅ shimming.pro actualizado para Raspberry Pi${NC}"

# ==================== RECOMPILAR ====================
echo -e "${BLUE}Recompilando para Raspberry Pi...${NC}"

make clean
rm -f Makefile
qmake
make -j4

if [ $? -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Adaptación a Raspberry Pi completada!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e ""
    echo -e "${YELLOW}Configuraciones aplicadas:${NC}"
    echo -e "  📱 Pantalla 800x480 optimizada"
    echo -e "  🎨 Estilo táctil con botones más grandes"
    echo -e "  🖱️ Soporte para pantalla táctil"
    echo -e "  🔌 Soporte GPIO (WiringPi)"
    echo -e "  🚀 Script de inicio automático"
    echo -e ""
    echo -e "${YELLOW}Para ejecutar:${NC}"
    echo -e "  ${GREEN}source qt_env.sh && ./bin/shimming${NC}"
    echo -e "  ${GREEN}./run_shimming.sh${NC}"
    echo -e ""
    echo -e "${YELLOW}Para inicio automático al boot:${NC}"
    echo -e "  ${GREEN}sudo systemctl enable shimming.service${NC}"
    echo -e "  ${GREEN}sudo systemctl start shimming.service${NC}"
    echo -e ""
    echo -e "${YELLOW}Configuración de pantalla táctil (si es necesaria):${NC}"
    echo -e "  ${GREEN}sudo apt install xserver-xorg-input-evdev${NC}"
    echo -e "  ${GREEN}sudo cp /usr/share/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/10-evdev.conf${NC}"
else
    echo -e "${RED}❌ Error en compilación para Raspberry Pi${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}¡Todo listo para usar en Raspberry Pi 4!${NC}"
echo -e "${BLUE}========================================${NC}"
