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
