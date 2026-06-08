#!/bin/bash

# Script para refactorizar y profesionalizar el proyecto shimming
# Crea un backup, luego sobrescribe los archivos con versiones mejoradas

set -e  # Detener en error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sin color

echo -e "${GREEN}=== Refactorizando proyecto shimming ===${NC}"

# Crear backup con timestamp
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "Creando backup en ${BACKUP_DIR}/"

# Copiar archivos relevantes al backup
cp -f config.cpp config.h file.cpp file.h fileshimming.cpp fileshimming.h \
      main.cpp mainwindow.cpp mainwindow.h rs232.cpp rs232.h \
      tableshimming.cpp tableshimming.h shimming.pro "$BACKUP_DIR/" 2>/dev/null || true

# ==================== file.h ====================
cat > file.h << 'EOF'
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

    // Genera nombre de archivo basado en fecha UTC-3 (Argentina)
    static QString generateLogFileName();

    // Operaciones con archivo
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

# ==================== file.cpp ====================
cat > file.cpp << 'EOF'
#include "file.h"
#include <QDateTime>
#include <QDebug>

FileHandler::FileHandler()
{
}

FileHandler::~FileHandler()
{
    close();
}

QString FileHandler::generateLogFileName()
{
    // Usar UTC y restar 3 horas (Argentina)
    QDateTime utc = QDateTime::currentDateTimeUtc();
    QDateTime argentina = utc.addSecs(-3 * 3600); // UTC-3 sin horario de verano

    QString fileName = QString("log%1%2%3%4%5%6.txt")
            .arg(argentina.date().year())
            .arg(argentina.date().month(), 2, 10, QLatin1Char('0'))
            .arg(argentina.date().day(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().hour(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().minute(), 2, 10, QLatin1Char('0'))
            .arg(argentina.time().second(), 2, 10, QLatin1Char('0'));

    qDebug() << "Nombre de archivo generado:" << fileName;
    return fileName;
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

# ==================== fileshimming.h ====================
cat > fileshimming.h << 'EOF'
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
    void ConfigDate();  // Genera nombre y abre archivo automáticamente

protected:
    FileHandler m_fileHandler;
    bool m_isOpen;
};

#endif // FILESHIMMING_H
EOF

# ==================== fileshimming.cpp ====================
cat > fileshimming.cpp << 'EOF'
#include "fileshimming.h"
#include <QDebug>

FileShimming::FileShimming() : m_isOpen(false)
{
}

FileShimming::~FileShimming()
{
    CloseFileShimming();
}

void FileShimming::setFileShimming(const QString &fileName)
{
    if (m_fileHandler.open(fileName, QIODevice::ReadWrite)) {
        m_isOpen = true;
        qDebug() << "Archivo establecido:" << fileName;
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
    QString fileName = FileHandler::generateLogFileName();
    setFileShimming(fileName);
}
EOF

# ==================== config.h (eliminado, ya no se usa) ====================
# Se puede dejar vacío o eliminarlo. Prevenimos errores creando uno vacío.
cat > config.h << 'EOF'
// config.h - Obsoleto. El proyecto ya no usa esta clase.
#ifndef CONFIG_H
#define CONFIG_H
// Este archivo se mantiene por compatibilidad, pero no es necesario.
#endif
EOF

cat > config.cpp << 'EOF'
// config.cpp - Obsoleto.
#include "config.h"
EOF

# ==================== rs232.h (sin cambios mayores, solo limpieza) ====================
cat > rs232.h << 'EOF'
#ifndef RS232_H
#define RS232_H

#include <qextserialport.h>
#include <QObject>

class RS232 : public QObject
{
    Q_OBJECT
public:
    explicit RS232(QObject *parent = nullptr);
    ~RS232();

    void putFrecuency();
    bool getConnectSerialPort();
    QextSerialPort *getSerialPort(void);

private slots:
    void updateReceivedData();  // Cambiado a void

private:
    QextSerialPort *serialPortRs232;
    int m_quantity_bytes_send;
    int m_quantity_bytes_received;
    QString receivedData;
};

#endif // RS232_H
EOF

# ==================== rs232.cpp (correcciones en slot y manejo de datos) ====================
cat > rs232.cpp << 'EOF'
#include "rs232.h"
#include "qextserialenumerator.h"
#include <QDebug>

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

    // Ejemplo: procesar cuando se tienen al menos 7 bytes (ajustar según necesidad)
    if (receivedData.length() >= 7) {
        qDebug() << "Datos recibidos:" << receivedData;
        receivedData.clear();
    }
}

bool RS232::getConnectSerialPort()
{
    if (!serialPortRs232) {
        QString sPort = "/dev/ttyUSB0"; // Se puede hacer más dinámico
        serialPortRs232 = new QextSerialPort(sPort, QextSerialPort::EventDriven);

        serialPortRs232->setBaudRate(BAUD2400);
        serialPortRs232->setFlowControl(FLOW_OFF);
        serialPortRs232->setParity(PAR_NONE);
        serialPortRs232->setDataBits(DATA_8);
        serialPortRs232->setStopBits(STOP_1);

        if (serialPortRs232->open(QIODevice::ReadWrite)) {
            qDebug() << "Puerto serie abierto correctamente.";
            connect(serialPortRs232, SIGNAL(readyRead()), this, SLOT(updateReceivedData()));
            return true;
        } else {
            qDebug() << "Error al abrir el puerto serie.";
            delete serialPortRs232;
            serialPortRs232 = nullptr;
            return false;
        }
    } else {
        // Si ya existe, lo cerramos y eliminamos (toggle)
        qDebug() << "Cerrando puerto serie...";
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

QextSerialPort *RS232::getSerialPort()
{
    return serialPortRs232;
}
EOF

# ==================== tableshimming.h (sin cambios mayores) ====================
cat > tableshimming.h << 'EOF'
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
    QString write_shimming(const char *txt);  // const char*
};

#endif // TABLESHIMMING_H
EOF

# ==================== tableshimming.cpp (pequeño ajuste) ====================
cat > tableshimming.cpp << 'EOF'
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

# ==================== mainwindow.h (eliminar herencia de Config y limpiar) ====================
cat > mainwindow.h << 'EOF'
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

# ==================== mainwindow.cpp (ajustar includes y eliminar referencias a Config) ====================
cat > mainwindow.cpp << 'EOF'
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDebug>
#include <QScrollBar>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->tabWidget->setCurrentIndex(0);
    memberSerialPort = new RS232(this);
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
    ConfigDate();  // Heredado de FileShimming
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
    // Podría implementarse si se necesita leer datos del puerto serie en la ventana principal
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

# ==================== main.cpp (mejorar splash con rutas relativas) ====================
cat > main.cpp << 'EOF'
#include "mainwindow.h"
#include <QApplication>
#include <QSplashScreen>
#include <QTimer>
#include <QDebug>
#include <QIcon>
#include <QPixmap>
#include <QDir>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QSplashScreen splash;
    QString splashPath = QDir::currentPath() + "/icons/animal.png";
    if (QFile::exists(splashPath)) {
        splash.setPixmap(QPixmap(splashPath));
    } else {
        qDebug() << "No se encontró splash image en" << splashPath;
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

# ==================== shimming.pro (ajustar ruta de qextserialport) ====================
cat > shimming.pro << 'EOF'
#-------------------------------------------------
# Project created by QtCreator 2018-05-18T15:13:33
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = shimming
TEMPLATE = app

SOURCES += main.cpp \
    mainwindow.cpp \
    fileshimming.cpp \
    tableshimming.cpp \
    rs232.cpp \
    file.cpp

HEADERS  += mainwindow.h \
    fileshimming.h \
    tableshimming.h \
    rs232.h \
    file.h

FORMS    += mainwindow.ui

# Ajusta esta ruta según la ubicación real de qextserialport en tu sistema
# Por ejemplo, si lo instalaste en /usr/local/qextserialport, cambia la línea.
# Si prefieres usar el sistema de paquetes, comenta la siguiente línea y descomenta la otra.
include(/usr/local/qextserialport/src/qextserialport.pri)
# CONFIG += link_pkgconfig
# PKGCONFIG += qextserialport-qt5
EOF

echo -e "${GREEN}✅ Refactorización completada. Los archivos originales fueron respaldados en ${BACKUP_DIR}/${NC}"
echo -e "${GREEN}▶️  Ahora ejecute qmake && make para compilar.${NC}"
