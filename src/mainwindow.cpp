#include "mainwindow.hpp"
#include "ui_mainwindow.h"

#include "tableshimming.hpp"
#include "fileshimming.hpp"
#include "rs232.hpp"

#include <QDebug>
#include <QScrollBar>
#include <QDir>

/*
 * ── Constructor ──────────────────────────────────────────────────────────────
 *
 * Initialises the UI from the .ui designer file, then creates the three
 * subsystem objects.  All three are intentionally heap-allocated so their
 * lifetimes are independent of the stack and can be freely re-ordered
 * in the destructor without risking use-after-free in parent-child
 * signal/slot chains.
 */
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    m_serialPort     = new RS232(this);          // QObject parent → auto-delete
    m_tableShimming  = new TableShimming();
    m_fileShimming   = new FileShimming();

    ui->tabWidget->setCurrentIndex(0);

    // Ensure working directories exist (no-op if already present)
    QDir().mkpath("logs");
    QDir().mkpath("plots");

    qDebug() << "MainWindow: initialised";
}

MainWindow::~MainWindow()
{
    delete m_tableShimming;
    delete m_fileShimming;
    delete ui;
    // m_serialPort is deleted by QObject parent mechanism
}

/*
 * ── Serial port toggle ───────────────────────────────────────────────────────
 *
 * Delegates to RS232; updates the button text and switches to the
 * config tab on successful connection to give the operator immediate
 * visual feedback.
 */
void MainWindow::on_pushButton_rs232_clicked()
{
    if (m_serialPort->getConnectSerialPort()) {
        ui->pushButton_rs232->setText("Disconnect");
        ui->tabWidget->setCurrentIndex(2);
    } else {
        ui->pushButton_rs232->setText("Connect");
    }
}

/*
 * ── File operations ─────────────────────────────────────────────────────────
 *
 * create_file: switches to the config tab and generates a new log filename
 *              based on the current (Argentina) timestamp.
 * file_exit:   closes the currently open log file.
 * save:        persists the plain-text editor contents to the open file.
 */
void MainWindow::on_pushButton_create_file_clicked()
{
    ui->tabWidget->setCurrentIndex(1);
    m_fileShimming->ConfigDate();
}

void MainWindow::on_pushButton_file_exit_clicked()
{
    m_fileShimming->CloseFileShimming();
}

void MainWindow::on_pushButton_save_clicked()
{
    const QString text = ui->plainTextEdit->toPlainText();
    qDebug() << "MainWindow: saving text, length =" << text.length();
    m_fileShimming->saveFileShimming(text);
}

/*
 * ── Measurement recording ────────────────────────────────────────────────────
 *
 * Advances one step in the measurement protocol each time RECORD is pressed.
 * The step counter resets automatically after the last plane.
 *
 * Scalability note: totalSteps() is computed from the size of the internal
 * data arrays in TableShimming, so adding planes or indexes automatically
 * extends the measurement cycle.
 */
void MainWindow::on_pushButton_record_clicked()
{
    static int step = 0;

    const QString measurement = m_tableShimming->get_measurement(step);
    qDebug() << "MainWindow: step" << step;
    ui->plainTextEdit->insertPlainText(measurement);

    step++;
    if (step >= m_tableShimming->totalSteps())
        step = 0;
}

/*
 * ── Frequency display ────────────────────────────────────────────────────────
 *
 * Reads the frequency line-edit and appends it to the measurement log
 * with an "Hz" suffix.  This is a UI-only operation; the actual frequency
 * transmission is handled by putFrecuency.
 */
void MainWindow::on_pushButton_get_shim_clicked()
{
    const QByteArray send = ui->lineEdit_frecuency->text().toLocal8Bit();
    ui->plainTextEdit->insertPlainText(" ");
    ui->plainTextEdit->insertPlainText(QString::fromLocal8Bit(send));
    ui->plainTextEdit->insertPlainText("Hz ");
    ui->plainTextEdit->setCenterOnScroll(true);
    ui->plainTextEdit->centerCursor();
    qDebug() << "MainWindow: get shim" << send << "Hz";
}

/*
 * ── Data reception (stub) ────────────────────────────────────────────────────
 *
 * Reserved for future use.  Connect RS232::dataReceived to this slot
 * when the incoming-spectrometer-data display is implemented.
 */
void MainWindow::onReceivedData()
{
}

/*
 * ── Frequency transmission ───────────────────────────────────────────────────
 *
 * Sends the current frequency via RS232 and updates the display with the
 * new value.  The frequency auto-increments inside putFrecuency().
 */
void MainWindow::on_pushButton_putFrecuency_clicked()
{
    m_serialPort->putFrecuency();

    /*
     * The displayed frequency trails the transmitted one by one step
     * because the increment happens inside putFrecuency().  This matches
     * the original behaviour; keep both in sync if the protocol changes.
     */
    static int frecuencia = 8540000;
    ui->lineEdit_frecuency->setText(QString::number(frecuencia));
    qDebug() << "MainWindow: display frequency" << frecuencia;
    frecuencia++;
}
