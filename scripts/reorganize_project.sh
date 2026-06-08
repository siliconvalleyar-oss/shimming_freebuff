#!/bin/bash

# Script para reorganizar el proyecto shimming
# Mueve archivos a src/, include/, y configura directorios para logs, plots y obj

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Reorganización de Shimming Project${NC}"
echo -e "${BLUE}========================================${NC}"

# ==================== CREAR ESTRUCTURA DE DIRECTORIOS ====================
echo -e "${YELLOW}Creando estructura de directorios...${NC}"

mkdir -p src
mkdir -p include
mkdir -p bin
mkdir -p logs
mkdir -p plots
mkdir -p obj
mkdir -p icons
mkdir -p scripts

echo -e "${GREEN}✅ Directorios creados: src/, include/, bin/, logs/, plots/, obj/${NC}"

# ==================== RESPALDAR ARCHIVOS ====================
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}Creando backup en ${BACKUP_DIR}/...${NC}"
mkdir -p "$BACKUP_DIR"
cp *.cpp *.h *.pro *.ui Makefile 2>/dev/null "$BACKUP_DIR/" || true
echo -e "${GREEN}✅ Backup creado${NC}"

# ==================== MOVER ARCHIVOS .cpp A src/ ====================
echo -e "${BLUE}Moviendo archivos .cpp a src/...${NC}"
mv -f main.cpp src/ 2>/dev/null || true
mv -f mainwindow.cpp src/ 2>/dev/null || true
mv -f rs232.cpp src/ 2>/dev/null || true
mv -f file.cpp src/ 2>/dev/null || true
mv -f fileshimming.cpp src/ 2>/dev/null || true
mv -f tableshimming.cpp src/ 2>/dev/null || true
mv -f config.cpp src/ 2>/dev/null || true

echo -e "${GREEN}✅ Archivos .cpp movidos a src/${NC}"

# ==================== MOVER ARCHIVOS .h A include/ ====================
echo -e "${BLUE}Moviendo archivos .h a include/...${NC}"
mv -f mainwindow.h include/ 2>/dev/null || true
mv -f rs232.h include/ 2>/dev/null || true
mv -f file.h include/ 2>/dev/null || true
mv -f fileshimming.h include/ 2>/dev/null || true
mv -f tableshimming.h include/ 2>/dev/null || true
mv -f config.h include/ 2>/dev/null || true

echo -e "${GREEN}✅ Archivos .h movidos a include/${NC}"

# ==================== MOVER ARCHIVOS UI ====================
echo -e "${BLUE}Moviendo archivos .ui...${NC}"
mv -f mainwindow.ui src/ 2>/dev/null || true

echo -e "${GREEN}✅ Archivos .ui movidos a src/${NC}"

# ==================== CREAR NUEVO shimming.pro ====================
echo -e "${BLUE}Creando nuevo shimming.pro...${NC}"
cat > shimming.pro << 'EOF'
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
EOF

echo -e "${GREEN}✅ shimming.pro actualizado con directorio obj/${NC}"

# ==================== ACTUALIZAR include/fileshimming.h ====================
echo -e "${BLUE}Actualizando include/fileshimming.h...${NC}"
cat > include/fileshimming.h << 'EOF'
#ifndef FILESHIMMING_H
#define FILESHIMMING_H

#include <QString>
#include "file.h"

class FileShimming
{
public:
    FileShimming();
    virtual ~FileShimming();
    
    void setFileShimming(const QString &fileName);
    void CloseFileShimming();
    void saveFileShimming(const QString &bytes);
    void ConfigDate();
    void setLogDirectory(const QString &dir);
    
protected:
    FileHandler m_fileHandler;
    bool m_isOpen;
    QString m_logDirectory;
};

#endif // FILESHIMMING_H
EOF

# ==================== ACTUALIZAR src/fileshimming.cpp ====================
echo -e "${BLUE}Actualizando src/fileshimming.cpp...${NC}"
cat > src/fileshimming.cpp << 'EOF'
#include "fileshimming.h"
#include <QDebug>
#include <QDir>
#include <QDateTime>

FileShimming::FileShimming() : m_isOpen(false)
{
    // Establecer directorio de logs
    #ifdef LOG_DIR
        m_logDirectory = QString(LOG_DIR);
    #else
        m_logDirectory = "logs/";
    #endif
    
    // Crear directorio de logs si no existe
    QDir dir;
    if (!dir.exists(m_logDirectory)) {
        dir.mkpath(m_logDirectory);
        qDebug() << "Directorio de logs creado:" << m_logDirectory;
    }
}

FileShimming::~FileShimming()
{
    CloseFileShimming();
}

void FileShimming::setLogDirectory(const QString &dir)
{
    m_logDirectory = dir;
    QDir dirObj;
    if (!dirObj.exists(m_logDirectory)) {
        dirObj.mkpath(m_logDirectory);
    }
}

void FileShimming::setFileShimming(const QString &fileName)
{
    QString fullPath = m_logDirectory + fileName;
    if (m_fileHandler.open(fullPath, QIODevice::ReadWrite)) {
        m_isOpen = true;
        qDebug() << "Archivo establecido:" << fullPath;
    } else {
        m_isOpen = false;
    }
}

void FileShimming::CloseFileShimming()
{
    if (m_isOpen) {
        m_fileHandler.close();
        m_isOpen = false;
    }
}

void FileShimming::saveFileShimming(const QString &bytes)
{
    if (m_isOpen) {
        m_fileHandler.write(bytes);
    } else {
        qDebug() << "ERROR: No se puede guardar, archivo no abierto.";
    }
}

void FileShimming::ConfigDate()
{
    QDateTime utc = QDateTime::currentDateTimeUtc();
    QDateTime argentina = utc.addSecs(-3 * 3600);
    
    QString fileName = QString("log%1%2%3%4%5%6.txt")
            .arg(argentina.date().year())
            .arg(argentina.date().month(), 2, 10, QLatin1Char('0'))
            .arg(argentina.date().day(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().hour(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().minute(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().second(), 2, 10, QLatin1Char('0'));
    
    qDebug() << "Nombre de archivo generado:" << fileName;
    setFileShimming(fileName);
}
EOF

# ==================== ACTUALIZAR include/file.h ====================
cat > include/file.h << 'EOF'
#ifndef FILE_H
#define FILE_H

#include <QString>
#include <QFile>
#include <QTextStream>

class FileHandler
{
public:
    explicit FileHandler();
    ~FileHandler();
    
    bool open(const QString &fileName, QIODevice::OpenMode mode = QIODevice::ReadWrite);
    void close();
    bool isOpen() const;
    bool write(const QString &data);
    QString readAll();
    
private:
    QFile m_file;
    QTextStream m_stream;
};

#endif // FILE_H
EOF

# ==================== ACTUALIZAR src/file.cpp ====================
cat > src/file.cpp << 'EOF'
#include "file.h"
#include <QDebug>

FileHandler::FileHandler()
{
}

FileHandler::~FileHandler()
{
    close();
}

bool FileHandler::open(const QString &fileName, QIODevice::OpenMode mode)
{
    if (m_file.isOpen())
        close();
    
    m_file.setFileName(fileName);
    if (!m_file.open(mode)) {
        qDebug() << "ERROR: No se pudo abrir el archivo" << fileName;
        return false;
    }
    m_stream.setDevice(&m_file);
    qDebug() << "Archivo abierto:" << fileName;
    return true;
}

void FileHandler::close()
{
    if (m_file.isOpen()) {
        m_stream.flush();
        m_file.close();
        qDebug() << "Archivo cerrado.";
    }
}

bool FileHandler::isOpen() const
{
    return m_file.isOpen();
}

bool FileHandler::write(const QString &data)
{
    if (!m_file.isOpen()) {
        qDebug() << "ERROR: Archivo no abierto para escribir.";
        return false;
    }
    m_stream << data;
    m_stream.flush();
    return true;
}

QString FileHandler::readAll()
{
    if (!m_file.isOpen())
        return QString();
    m_file.seek(0);
    return m_stream.readAll();
}
EOF

# ==================== ACTUALIZAR include/mainwindow.h ====================
cat > include/mainwindow.h << 'EOF'
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "tableshimming.h"
#include "fileshimming.h"
#include "rs232.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow, public TableShimming, public FileShimming
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_pushButton_rs232_clicked();
    void on_pushButton_create_file_clicked();
    void on_pushButton_file_exit_clicked();
    void on_pushButton_record_clicked();
    void on_pushButton_get_shim_clicked();
    void onReceivedData();
    void on_pushButton_putFrecuency_clicked();
    void on_pushButton_save_clicked();

private:
    Ui::MainWindow *ui;
    RS232 *memberSerialPort;
};

#endif // MAINWINDOW_H
EOF

# ==================== ACTUALIZAR src/mainwindow.cpp ====================
cat > src/mainwindow.cpp << 'EOF'
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDebug>
#include <QScrollBar>
#include <QDir>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->tabWidget->setCurrentIndex(0);
    memberSerialPort = new RS232(this);
    
    // Crear directorios necesarios
    QDir dir;
    dir.mkpath("logs");
    dir.mkpath("plots");
}

MainWindow::~MainWindow()
{
    delete ui;
    delete memberSerialPort;
}

void MainWindow::on_pushButton_rs232_clicked()
{
    if (memberSerialPort->getConnectSerialPort()) {
        ui->pushButton_rs232->setText("Disconnect");
        ui->tabWidget->setCurrentIndex(2);
    } else {
        ui->pushButton_rs232->setText("Connect");
    }
}

void MainWindow::on_pushButton_create_file_clicked()
{
    ui->tabWidget->setCurrentIndex(1);
    ConfigDate();
}

void MainWindow::on_pushButton_file_exit_clicked()
{
    CloseFileShimming();
}

void MainWindow::on_pushButton_record_clicked()
{
    static int step = 0;
    QString measurement = get_measurement(step);
    qDebug() << "step:" << step;
    step++;
    if (step >= 136)
        step = 0;
    ui->plainTextEdit->insertPlainText(measurement);
}

void MainWindow::on_pushButton_get_shim_clicked()
{
    QByteArray send = ui->lineEdit_frecuency->text().toLocal8Bit();
    ui->plainTextEdit->insertPlainText(" ");
    ui->plainTextEdit->insertPlainText(send);
    ui->plainTextEdit->insertPlainText("Hz ");
    ui->plainTextEdit->setCenterOnScroll(true);
    ui->plainTextEdit->centerCursor();
    qDebug() << "Frecuencia:" << send << "Hz";
}

void MainWindow::onReceivedData()
{
    // Implementar si es necesario
}

void MainWindow::on_pushButton_putFrecuency_clicked()
{
    static int frecuencia = 8540000;
    QString strFrecuencia;
    memberSerialPort->putFrecuency();
    strFrecuencia.setNum(frecuencia);
    qDebug() << "strFrecuencia:" << strFrecuencia;
    ui->lineEdit_frecuency->setText(strFrecuencia);
    frecuencia++;
}

void MainWindow::on_pushButton_save_clicked()
{
    QString texto = ui->plainTextEdit->toPlainText();
    qDebug() << "Guardando texto:" << texto;
    saveFileShimming(texto);
}
EOF

# ==================== ACTUALIZAR src/rs232.cpp ====================
cat > src/rs232.cpp << 'EOF'
#include "rs232.h"
#include <QDebug>
#include <QSerialPortInfo>

RS232::RS232(QObject *parent) : 
    QObject(parent), serialPortRs232(nullptr)
{
}

RS232::~RS232()
{
    delete serialPortRs232;
}

void RS232::updateReceivedData()
{
    if (!serialPortRs232)
        return;
    
    QByteArray data = serialPortRs232->readAll();
    receivedData.append(QString::fromLatin1(data));
    
    if (receivedData.length() >= 7) {
        qDebug() << "Datos recibidos:" << receivedData;
        receivedData.clear();
    }
}

bool RS232::getConnectSerialPort()
{
    if (!serialPortRs232) {
        serialPortRs232 = new QSerialPort(this);
        serialPortRs232->setPortName("/dev/ttyUSB0");
        serialPortRs232->setBaudRate(QSerialPort::Baud2400);
        serialPortRs232->setDataBits(QSerialPort::Data8);
        serialPortRs232->setParity(QSerialPort::NoParity);
        serialPortRs232->setStopBits(QSerialPort::OneStop);
        serialPortRs232->setFlowControl(QSerialPort::NoFlowControl);
        
        if (serialPortRs232->open(QIODevice::ReadWrite)) {
            qDebug() << "Puerto serie abierto correctamente.";
            connect(serialPortRs232, &QSerialPort::readyRead, 
                    this, &RS232::updateReceivedData);
            return true;
        } else {
            qDebug() << "Error al abrir el puerto serie.";
            delete serialPortRs232;
            serialPortRs232 = nullptr;
            return false;
        }
    } else {
        qDebug() << "Cerrando puerto serie...";
        serialPortRs232->close();
        delete serialPortRs232;
        serialPortRs232 = nullptr;
        return false;
    }
}

void RS232::putFrecuency()
{
    static int frecuencia = 8540001;
    if (serialPortRs232 && serialPortRs232->isOpen()) {
        QByteArray cmd = QByteArray::number(frecuencia);
        serialPortRs232->write(cmd);
        qDebug() << "Enviando frecuencia:" << cmd;
        frecuencia++;
    } else {
        qDebug() << "Puerto no disponible para enviar frecuencia.";
    }
}

QSerialPort *RS232::getSerialPort()
{
    return serialPortRs232;
}
EOF

# ==================== ACTUALIZAR include/rs232.h ====================
cat > include/rs232.h << 'EOF'
#ifndef RS232_H
#define RS232_H

#include <QObject>
#include <QSerialPort>

class RS232 : public QObject
{
    Q_OBJECT
public:
    explicit RS232(QObject *parent = nullptr);
    ~RS232();
    
    void putFrecuency();
    bool getConnectSerialPort();
    QSerialPort *getSerialPort(void);
    
private slots:
    void updateReceivedData();
    
private:
    QSerialPort *serialPortRs232;
    int m_quantity_bytes_send;
    int m_quantity_bytes_received;
    QString receivedData;
};

#endif // RS232_H
EOF

# ==================== ACTUALIZAR include/tableshimming.h ====================
cat > include/tableshimming.h << 'EOF'
#ifndef TABLESHIMMING_H
#define TABLESHIMMING_H

#include <QString>

typedef enum {
    F0BASE,
    PLANE_1,
    PLANE_2,
    PLANE_3,
    PLANE_4,
    PLANE_5,
    PLANE_6,
    PLANE_7,
    PLANE_8,
    PLANE_9,
    PLANE_10,
    PLANE_11,
    PLANE_12,
    PLANE_13,
    ISOCENTRO
} PLANE;

typedef enum {
    INDEX_0,
    INDEX_30,
    INDEX_60,
    INDEX_90,
    INDEX_120,
    INDEX_150,
    INDEX_180,
    INDEX_210,
    INDEX_240,
    INDEX_270,
    INDEX_300,
    INDEX_330
} INDEX_GRADE;

class TableShimming
{
public:
    TableShimming();
    QString get_measurement(int step);
    QString insert_index(int index);
    QString insert_plane(int plane);
    QString write_shimming(const char *txt);
};

#endif // TABLESHIMMING_H
EOF

# ==================== ACTUALIZAR src/tableshimming.cpp ====================
cat > src/tableshimming.cpp << 'EOF'
#include "tableshimming.h"
#include <QDebug>

TableShimming::TableShimming()
{
}

QString TableShimming::get_measurement(int step)
{
    static int counter_plane = 0;
    static int counter_multi_plane = 0;
    QString text_measurement;

    if (step == 0) {
        text_measurement = insert_plane(F0BASE);
    }
    else if (step == 1) {
        text_measurement = insert_plane(PLANE_1);
        text_measurement += insert_index(INDEX_0);
    }
    else if (step >= 2 && step <= 133) {
        switch (counter_plane) {
        case 0:
            text_measurement = insert_plane(counter_multi_plane + 2);
            text_measurement += insert_index(INDEX_0);
            break;
        case 1: text_measurement = insert_index(INDEX_30); break;
        case 2: text_measurement = insert_index(INDEX_60); break;
        case 3: text_measurement = insert_index(INDEX_90); break;
        case 4: text_measurement = insert_index(INDEX_120); break;
        case 5: text_measurement = insert_index(INDEX_150); break;
        case 6: text_measurement = insert_index(INDEX_180); break;
        case 7: text_measurement = insert_index(INDEX_210); break;
        case 8: text_measurement = insert_index(INDEX_240); break;
        case 9: text_measurement = insert_index(INDEX_270); break;
        case 10: text_measurement = insert_index(INDEX_300); break;
        case 11: text_measurement = insert_index(INDEX_330); break;
        default: break;
        }
        counter_plane++;
        if (counter_plane >= 12) {
            counter_plane = 0;
            counter_multi_plane++;
        }
        if (counter_multi_plane == 13) {
            counter_multi_plane = 0;
        }
    }
    else if (step == 134) {
        text_measurement = insert_plane(PLANE_13);
        text_measurement += insert_index(INDEX_0);
    }
    else if (step == 135) {
        text_measurement = insert_plane(ISOCENTRO);
    }
    else if (step >= 136) {
        counter_plane = 0;
        counter_multi_plane = 0;
    }

    return text_measurement;
}

QString TableShimming::insert_plane(int plane)
{
    switch (plane) {
    case F0BASE:   return write_shimming("\r\n\r\nF0 Base ISOCENTRO\t");
    case PLANE_1:  return write_shimming("\r\n\r\nPLANO 1");
    case PLANE_2:  return write_shimming("\r\n\r\nPLANO 2");
    case PLANE_3:  return write_shimming("\r\n\r\nPLANO 3");
    case PLANE_4:  return write_shimming("\r\n\r\nPLANO 4");
    case PLANE_5:  return write_shimming("\r\n\r\nPLANO 5");
    case PLANE_6:  return write_shimming("\r\n\r\nPLANO 6");
    case PLANE_7:  return write_shimming("\r\n\r\nPLANO 7");
    case PLANE_8:  return write_shimming("\r\n\r\nPLANO 8");
    case PLANE_9:  return write_shimming("\r\n\r\nPLANO 9");
    case PLANE_10: return write_shimming("\r\n\r\nPLANO 10");
    case PLANE_11: return write_shimming("\r\n\r\nPLANO 11");
    case PLANE_12: return write_shimming("\r\n\r\nPLANE 12");
    case PLANE_13: return write_shimming("\r\n\r\nPLANE 13");
    case ISOCENTRO:return write_shimming("\r\n\r\nISOCENTRO\t");
    default: return QString();
    }
}

QString TableShimming::insert_index(int index)
{
    switch (index) {
    case INDEX_0:   return write_shimming("\t[0°]");
    case INDEX_30:  return write_shimming("\t[30°]");
    case INDEX_60:  return write_shimming("\t[60°]");
    case INDEX_90:  return write_shimming("\t[90°]");
    case INDEX_120: return write_shimming("\t[120°]");
    case INDEX_150: return write_shimming("\t[150°]");
    case INDEX_180: return write_shimming("\t[180°]");
    case INDEX_210: return write_shimming("\t[210°]");
    case INDEX_240: return write_shimming("\t[240°]");
    case INDEX_270: return write_shimming("\t[270°]");
    case INDEX_300: return write_shimming("\t[300°]");
    case INDEX_330: return write_shimming("\t[330°]");
    default: return QString();
    }
}

QString TableShimming::write_shimming(const char *txt)
{
    qDebug() << txt;
    return QString::fromLatin1(txt);
}
EOF

# ==================== ACTUALIZAR src/main.cpp ====================
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

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    
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
        splash.setPixmap(QPixmap(200, 200));
        splash.showMessage("Cargando...");
    }
    splash.setWindowOpacity(0.95);
    splash.show();
    QTimer::singleShot(500, &splash, &QSplashScreen::close);
    
    MainWindow w;
    QString iconPath = QDir::currentPath() + "/icons/icon.png";
    if (QFile::exists(iconPath))
        w.setWindowIcon(QIcon(iconPath));
    w.show();
    
    return a.exec();
}
EOF

# ==================== CREAR ARCHIVO CONFIG OBSOLETO ====================
cat > include/config.h << 'EOF'
// config.h - Archivo obsoleto. Mantenido por compatibilidad.
#ifndef CONFIG_H
#define CONFIG_H

class Config {
public:
    Config() {}
    void ConfigDate() {}
    void CloseFile() {}
    void setFileShimming(char*) {}
};

#endif // CONFIG_H
EOF

cat > src/config.cpp << 'EOF'
// config.cpp - Archivo obsoleto
#include "config.h"
EOF

# ==================== LIMPIEZA Y COMPILACIÓN ====================
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Realizando limpieza profunda...${NC}"

# Limpiar archivos generados
make clean 2>/dev/null || true
rm -f Makefile
rm -f Makefile.Debug
rm -f Makefile.Release
rm -f ui_mainwindow.h
rm -f *.o
rm -f moc_*.cpp
rm -f moc_*.h
rm -f qrc_*.cpp
rm -f *.moc
rm -f bin/shimming

# Limpiar directorio obj/
rm -rf obj/
mkdir -p obj

echo -e "${GREEN}✅ Limpieza completada, directorio obj/ recreado${NC}"

# ==================== REGENERAR MAKEFILE ====================
echo -e "${BLUE}Regenerando Makefile con qmake...${NC}"
qmake

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Makefile generado correctamente${NC}"
else
    echo -e "${RED}❌ Error generando Makefile${NC}"
    exit 1
fi

# ==================== COMPILACIÓN ====================
echo -e "${BLUE}Compilando proyecto...${NC}"
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Compilación exitosa!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e ""
    echo -e "${YELLOW}Estructura del proyecto:${NC}"
    echo -e "  📁 src/     - Archivos fuente (.cpp)"
    echo -e "  📁 include/ - Archivos de cabecera (.h)"
    echo -e "  📁 obj/     - Archivos objeto (.o) y temporales"
    echo -e "     ├── moc/     - Meta-object compiler files"
    echo -e "     ├── rcc/     - Resource compiler files"
    echo -e "     └── ui/      - UI compiler files"
    echo -e "  📁 bin/     - Ejecutable generado"
    echo -e "  📁 logs/    - Archivos .log generados"
    echo -e "  📁 plots/   - Archivos .plot generados"
    echo -e "  📁 icons/   - Iconos de la aplicación"
    echo -e ""
    echo -e "${YELLOW}Para ejecutar el programa:${NC}"
    echo -e "  ${GREEN}./bin/shimming${NC}"
    echo -e "  ${GREEN}cd bin && ./shimming${NC}"
    echo -e ""
    echo -e "${YELLOW}Backup guardado en: ${BACKUP_DIR}/${NC}"
    
    # Crear un enlace simbólico en la raíz para fácil acceso
    ln -sf bin/shimming shimming 2>/dev/null || true
    echo -e "${GREEN}✅ Enlace simbólico 'shimming' creado en la raíz${NC}"
    
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ Error en la compilación${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}Revisa los mensajes de error arriba${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}¡Reorganización completada con éxito!${NC}"
echo -e "${BLUE}========================================${NC}"
