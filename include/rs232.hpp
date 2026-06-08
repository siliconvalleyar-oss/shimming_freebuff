#ifndef RS232_H
#define RS232_H

#include <QObject>
#include <QSerialPort>

/*
 * RS232 serial-port manager for the NMR spectrometer communication.
 *
 * Ownership: serialPortRs232 is heap-allocated only while the port is
 * open and deleted immediately on disconnect. This avoids holding a
 * stale QSerialPort and simplifies resource tracking.
 *
 * Thread safety: this class is NOT reentrant. It must live on the
 * same thread as the Qt event loop that dispatches readyRead.
 *
 * Scalability: PortConfig struct centralises all configurable parameters
 * so changing baud rate, device path, or parity requires no code changes
 * in the connection logic.
 */

struct PortConfig {
    QString portName  = "/dev/ttyUSB0";
    int     baudRate  = QSerialPort::Baud2400;
    int     dataBits  = QSerialPort::Data8;
    int     parity    = QSerialPort::NoParity;
    int     stopBits  = QSerialPort::OneStop;
    int     flowCtrl  = QSerialPort::NoFlowControl;
};

class RS232 : public QObject
{
    Q_OBJECT

public:
    explicit RS232(QObject *parent = nullptr);
    ~RS232() override;

    /*
     * Toggles the serial-port connection.
     * Returns true if the port was successfully opened.
     * Returns false on error or if the port was already open (disconnect).
     */
    bool getConnectSerialPort();

    /*
     * Transmits the current frequency value over the serial line.
     * The frequency auto-increments on each call.
     * Silently no-ops if the serial port is not connected.
     */
    void putFrecuency();

    /*
     * Returns a pointer to the underlying QSerialPort (may be nullptr).
     * Provided for callers that need direct access (e.g. signal wiring).
     */
    QSerialPort *getSerialPort() const;

    /*
     * Replaces the current port configuration.
     * Only takes effect on the next getConnectSerialPort() call.
     */
    void setConfig(const PortConfig &config);
    const PortConfig &config() const;

signals:
    /*
     * Emitted when at least 7 bytes of data have been accumulated.
     * The UI layer connects here to display incoming spectrometer data.
     */
    void dataReceived(const QString &data);

private slots:
    /*
     * Internal slot wired to QSerialPort::readyRead.
     * Buffers incoming bytes and emits dataReceived() once
     * the threshold (7 bytes) is reached.
     */
    void updateReceivedData();

private:
    QSerialPort *serialPortRs232 = nullptr;
    PortConfig   m_config;
    int          m_quantity_bytes_send     = 0;
    int          m_quantity_bytes_received = 0;
    QString      receivedData;
};

#endif // RS232_H
