#include "rs232.hpp"
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
