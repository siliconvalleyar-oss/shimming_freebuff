#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

/*
 * Top-level application window for the NMR shimming control interface.
 *
 * Architecture — Composition over inheritance:
 *   - TableShimming and FileShimming are NOT base classes.
 *     They are owned as members to keep responsibilities separate:
 *       MainWindow       → UI orchestration only
 *       TableShimming    → measurement protocol generation
 *       FileShimming     → data persistence / file I/O
 *       RS232            → serial-port communication
 *
 *   This lets us test each component independently and swap
 *   implementations without touching the UI layer.
 *
 * Scalability:
 *   - New tabs/widgets can be added without touching existing slots.
 *   - The serial-port, file, and measurement subsystems are decoupled
 *     and can be replaced by mock objects for testing.
 */

class QTabWidget;
class QPlainTextEdit;
class QLineEdit;
class QPushButton;

class TableShimming;
class FileShimming;
class RS232;

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

private slots:
    void on_pushButton_rs232_clicked();
    void on_pushButton_create_file_clicked();
    void on_pushButton_file_exit_clicked();
    void on_pushButton_record_clicked();
    void on_pushButton_get_shim_clicked();
    void onReceivedData();
    void on_pushButton_putFrecuency_clicked();
    void on_pushButton_save_clicked();

private:
    Ui::MainWindow *ui;

    /*
     * Owned subsystems. Created in the constructor and destroyed
     * via QObject parent-child mechanism (RS232) or explicitly in
     * ~MainWindow (TableShimming, FileShimming).
     */
    RS232           *m_serialPort      = nullptr;
    TableShimming   *m_tableShimming   = nullptr;
    FileShimming    *m_fileShimming    = nullptr;
};

#endif // MAINWINDOW_H
