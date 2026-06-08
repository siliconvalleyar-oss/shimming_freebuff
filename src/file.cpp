#include "file.hpp"
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
