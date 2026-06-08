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
        qWarning() << "FileHandler: cannot open" << fileName
                    << m_file.errorString();
        return false;
    }

    m_stream.setDevice(&m_file);
    qDebug() << "FileHandler: opened" << fileName;
    return true;
}

void FileHandler::close()
{
    if (!m_file.isOpen())
        return;

    m_stream.flush();
    m_file.close();
    qDebug() << "FileHandler: closed";
}

bool FileHandler::isOpen() const
{
    return m_file.isOpen();
}

bool FileHandler::write(const QString &data)
{
    if (!m_file.isOpen()) {
        qWarning() << "FileHandler: write attempted on closed file";
        return false;
    }

    m_stream << data;
    m_stream.flush();
    return true;
}

QString FileHandler::readAll()
{
    if (!m_file.isOpen())
        return {};

    m_file.seek(0);
    return m_stream.readAll();
}
