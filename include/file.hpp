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
