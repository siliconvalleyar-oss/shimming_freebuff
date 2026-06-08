#ifndef FILE_H
#define FILE_H

#include <QString>
#include <QFile>
#include <QTextStream>

/*
 * RAII file wrapper that provides a QTextStream-based read/write interface.
 *
 * Unlike a raw QFile, this class:
 *   - Flushes on close automatically.
 *   - Prevents double-open by closing first.
 *   - Exposes a safe isOpen() query.
 *
 * Not copyable (QFile is non-copyable).
 * Not thread-safe — use one FileHandler per thread.
 */
class FileHandler
{
public:
    explicit FileHandler();
    ~FileHandler();

    /*
     * Opens a file.  If a file is already open it is closed first.
     * Returns true on success.
     */
    bool open(const QString &fileName, QIODevice::OpenMode mode = QIODevice::ReadWrite);

    /*
     * Closes the file.  Safe to call even if already closed.
     */
    void close();

    /*
     * Returns true if a file is currently open.
     */
    bool isOpen() const;

    /*
     * Appends data to the file and flushes immediately.
     * Returns true on success, false if no file is open.
     */
    bool write(const QString &data);

    /*
     * Reads the entire file content from the beginning.
     * Returns an empty string if no file is open.
     *
     * WARNING: for large files this reads everything into memory.
     * For streaming, use QTextStream::readLine() directly on m_stream.
     */
    QString readAll();

private:
    QFile       m_file;
    QTextStream m_stream;
};

#endif // FILE_H
