#include "rs232.hpp"
#include <QDebug>
#include <QSerialPortInfo>

/*
 * NOTE: If the target device changes, modify m_config defaults in the
 * header or call setConfig() before getConnectSerialPort().
 */

RS232::RS232(QObject *parent)
    : QObject(parent)
{
}

RS232::~RS232()
{
    delete serialPortRs232;
}

/*
 * Toggle open/close for the serial port.
 *
 * The QSerialPort is created on open and destroyed on close so that:
 *   1. We never hold a stale file descriptor across a device hotplug.
 *   2. The destructor order is predictable (no dangling pointer).
 *   3. Memory overhead is zero when the port is not needed.
 */
bool RS232::getConnectSerialPort()
{
    if (!serialPortRs232) {
        auto *port = new QSerialPort(this);
        port->setPortName(m_config.portName);
        port->setBaudRate(m_config.baudRate);
        port->setDataBits(static_cast<QSerialPort::DataBits>(m_config.dataBits));
        port->setParity(static_cast<QSerialPort::Parity>(m_config.parity));
        port->setStopBits(static_cast<QSerialPort::StopBits>(m_config.stopBits));
        port->setFlowControl(static_cast<QSerialPort::FlowControl>(m_config.flowCtrl));

        if (port->open(QIODevice::ReadWrite)) {
            qDebug() << "RS232: opened" << m_config.portName;
            connect(port, &QSerialPort::readyRead,
                    this, &RS232::updateReceivedData);
            serialPortRs232 = port;
            return true;
        }

        qWarning() << "RS232: failed to open" << m_config.portName
                   << port->errorString();
        delete port;
        return false;
    }

    qDebug() << "RS232: closing port";
    serialPortRs232->close();
    delete serialPortRs232;
    serialPortRs232 = nullptr;
    return false;
}

/*
 * Incrementing frequency generator.
 *
 * The static counter starts at 8540001 and increases monotonically
 * for the lifetime of the process. This matches the behaviour of the
 * original spectrometer control software.
 *
 * TODO: make the start frequency configurable via PortConfig or
 * external calibration file if non-destructive testing is required.
 */
void RS232::putFrecuency()
{
    static int frecuencia = 8540001;

    if (!serialPortRs232 || !serialPortRs232->isOpen()) {
        qDebug() << "RS232: port not available, frequency not sent";
        return;
    }

    QByteArray cmd = QByteArray::number(frecuencia);
    qint64 written = serialPortRs232->write(cmd);
    if (written != cmd.size()) {
        qWarning() << "RS232: short write, expected" << cmd.size()
                   << "sent" << written;
    }
    qDebug() << "RS232: sent frequency" << cmd;
    frecuencia++;
}

QSerialPort *RS232::getSerialPort() const
{
    return serialPortRs232;
}

void RS232::setConfig(const PortConfig &config)
{
    m_config = config;
}

const PortConfig &RS232::config() const
{
    return m_config;
}

/*
 * Accumulates received bytes until we have at least 7, then emits
 * the accumulated data as a signal.
 *
 * The 7-byte threshold is empirical — it matches the expected response
 * format of the NMR spectrometer. If the protocol changes, adjust
 * the constant below.
 */
void RS232::updateReceivedData()
{
    if (!serialPortRs232)
        return;

    const QByteArray data = serialPortRs232->readAll();
    receivedData.append(QString::fromLatin1(data));

    if (receivedData.length() >= 7) {
        qDebug() << "RS232: received" << receivedData;
        emit dataReceived(receivedData);
        receivedData.clear();
    }
}
