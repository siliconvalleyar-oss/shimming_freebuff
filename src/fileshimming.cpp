#include "fileshimming.hpp"
#include <QDebug>
#include <QDir>
#include <QDateTime>

/*
 * Log-directory resolution:
 *   LOG_DIR → compile-time override (qmake DEFINES+=)
 *   default → "logs/" relative to the working directory
 */
FileShimming::FileShimming()
{
#ifdef LOG_DIR
    m_logDirectory = QString(LOG_DIR);
#else
    m_logDirectory = "logs/";
#endif

    // Idempotent — safe to call multiple times
    QDir().mkpath(m_logDirectory);
    qDebug() << "FileShimming: log directory" << m_logDirectory;
}

FileShimming::~FileShimming()
{
    CloseFileShimming();
}

void FileShimming::setLogDirectory(const QString &dir)
{
    m_logDirectory = dir;
    QDir().mkpath(m_logDirectory);
}

/*
 * fileName is treated as relative to m_logDirectory.
 * Full path: <logDirectory>/<fileName>
 */
void FileShimming::setFileShimming(const QString &fileName)
{
    const QString fullPath = m_logDirectory + fileName;

    if (m_fileHandler.open(fullPath, QIODevice::ReadWrite)) {
        m_isOpen = true;
        qDebug() << "FileShimming: active file" << fullPath;
    } else {
        m_isOpen = false;
        qWarning() << "FileShimming: failed to set file" << fullPath;
    }
}

void FileShimming::CloseFileShimming()
{
    if (!m_isOpen)
        return;

    m_fileHandler.close();
    m_isOpen = false;
    qDebug() << "FileShimming: file closed";
}

void FileShimming::saveFileShimming(const QString &bytes)
{
    if (!m_isOpen) {
        qWarning() << "FileShimming: cannot save — no file is open";
        return;
    }

    m_fileHandler.write(bytes);
}

/*
 * Generates a timestamped filename using Argentina time (UTC-3).
 *
 * This is intentional — the NMR facility operates in Argentina and the
 * logs are indexed by local time for traceability.
 *
 * TODO: make the time-zone offset configurable via a settings file
 * if the software is deployed in other regions.
 */
void FileShimming::ConfigDate()
{
    const QDateTime utc      = QDateTime::currentDateTimeUtc();
    const QDateTime argentina = utc.addSecs(-3 * 3600);

    const QString fileName = QString("log%1%2%3%4%5%6.txt")
        .arg(argentina.date().year())
        .arg(argentina.date().month(), 2, 10, QLatin1Char('0'))
        .arg(argentina.date().day(), 2, 10, QLatin1Char('0'))
        .arg(argentina.time().hour(), 2, 10, QLatin1Char('0'))
        .arg(argentina.time().minute(), 2, 10, QLatin1Char('0'))
        .arg(argentina.time().second(), 2, 10, QLatin1Char('0'));

    qDebug() << "FileShimming: generated filename" << fileName;
    setFileShimming(fileName);
}
