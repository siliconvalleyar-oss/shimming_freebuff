#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "tableshimming.h"
#include "fileshimming.h"
#include "rs232.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow, public TableShimming, public FileShimming
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

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
    RS232 *memberSerialPort;
};

#endif // MAINWINDOW_H
