#ifndef FILESHIMMING_H
#define FILESHIMMING_H

#include <QString>
#include "file.h"

class FileShimming
{
public:
    FileShimming();
    virtual ~FileShimming();
    
    void setFileShimming(const QString &fileName);
    void CloseFileShimming();
    void saveFileShimming(const QString &bytes);
    void ConfigDate();
    void setLogDirectory(const QString &dir);
    
protected:
    FileHandler m_fileHandler;
    bool m_isOpen;
    QString m_logDirectory;
};

#endif // FILESHIMMING_H
