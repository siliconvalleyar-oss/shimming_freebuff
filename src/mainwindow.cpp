#include "mainwindow.hpp"
#include "ui_mainwindow.h"
#include <QDebug>
#include <QScrollBar>
#include <QDir>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->tabWidget->setCurrentIndex(0);
    memberSerialPort = new RS232(this);
    
    // Crear directorios necesarios
    QDir dir;
    dir.mkpath("logs");
    dir.mkpath("plots");
}

MainWindow::~MainWindow()
{
    delete ui;
    delete memberSerialPort;
}

void MainWindow::on_pushButton_rs232_clicked()
{
    if (memberSerialPort->getConnectSerialPort()) {
        ui->pushButton_rs232->setText("Disconnect");
        ui->tabWidget->setCurrentIndex(2);
    } else {
        ui->pushButton_rs232->setText("Connect");
    }
}

void MainWindow::on_pushButton_create_file_clicked()
{
    ui->tabWidget->setCurrentIndex(1);
    ConfigDate();
}

void MainWindow::on_pushButton_file_exit_clicked()
{
    CloseFileShimming();
}

void MainWindow::on_pushButton_record_clicked()
{
    static int step = 0;
    QString measurement = get_measurement(step);
    qDebug() << "step:" << step;
    step++;
    if (step >= 136)
        step = 0;
    ui->plainTextEdit->insertPlainText(measurement);
}

void MainWindow::on_pushButton_get_shim_clicked()
{
    QByteArray send = ui->lineEdit_frecuency->text().toLocal8Bit();
    ui->plainTextEdit->insertPlainText(" ");
    ui->plainTextEdit->insertPlainText(send);
    ui->plainTextEdit->insertPlainText("Hz ");
    ui->plainTextEdit->setCenterOnScroll(true);
    ui->plainTextEdit->centerCursor();
    qDebug() << "Frecuencia:" << send << "Hz";
}

void MainWindow::onReceivedData()
{
    // Implementar si es necesario
}

void MainWindow::on_pushButton_putFrecuency_clicked()
{
    static int frecuencia = 8540000;
    QString strFrecuencia;
    memberSerialPort->putFrecuency();
    strFrecuencia.setNum(frecuencia);
    qDebug() << "strFrecuencia:" << strFrecuencia;
    ui->lineEdit_frecuency->setText(strFrecuencia);
    frecuencia++;
}

void MainWindow::on_pushButton_save_clicked()
{
    QString texto = ui->plainTextEdit->toPlainText();
    qDebug() << "Guardando texto:" << texto;
    saveFileShimming(texto);
}
