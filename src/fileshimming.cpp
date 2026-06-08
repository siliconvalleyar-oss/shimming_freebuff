#include "fileshimming.hpp"
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
