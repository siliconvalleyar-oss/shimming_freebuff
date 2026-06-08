#ifndef FILESHIMMING_H
#define FILESHIMMING_H

#include <QString>
#include "file.hpp"

/*
 * High-level file-management layer for shimming measurement logs.
 *
 * Wraps FileHandler with application-level semantics:
 *   - Automatic log-directory creation.
 *   - Timestamped file names via ConfigDate().
 *   - Compile-time overridable log path through the LOG_DIR macro.
 *
 * LOG_DIR can be defined in the .pro file or passed via qmake:
 *   qmake DEFINES+=LOG_DIR=\\\"/var/log/shimming\\\"
 */
class FileShimming
{
public:
    FileShimming();
    virtual ~FileShimming();

    /*
     * Sets the active log file within m_logDirectory.
     */
    void setFileShimming(const QString &fileName);

    /*
     * Closes the currently open log file, if any.
     */
    void CloseFileShimming();

    /*
     * Appends bytes to the current log file.
     */
    void saveFileShimming(const QString &bytes);

    /*
     * Generates a log filename from the current Argentina time
     * (UTC-3) and calls setFileShimming().
     *
     * Format: logYYYYMMDDHHmmSS.txt
     */
    void ConfigDate();

    /*
     * Overrides the default log directory ("logs/").
     * Creates the directory if it does not exist.
     */
    void setLogDirectory(const QString &dir);

protected:
    FileHandler m_fileHandler;
    bool        m_isOpen       = false;
    QString     m_logDirectory;
};

#endif // FILESHIMMING_H
