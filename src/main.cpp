#include "mainwindow.h"
#include <QApplication>
#include <QSplashScreen>
#include <QTimer>
#include <QDebug>
#include <QIcon>
#include <QPixmap>
#include <QDir>
#include <QFile>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    
    // Crear directorios necesarios
    QDir dir;
    dir.mkpath("icons");
    dir.mkpath("logs");
    dir.mkpath("plots");
    
    QSplashScreen splash;
    QString splashPath = QDir::currentPath() + "/icons/animal.png";
    if (QFile::exists(splashPath)) {
        splash.setPixmap(QPixmap(splashPath));
    } else {
        splash.setPixmap(QPixmap(200, 200));
        splash.showMessage("Cargando...");
    }
    splash.setWindowOpacity(0.95);
    splash.show();
    QTimer::singleShot(500, &splash, &QSplashScreen::close);
    
    MainWindow w;
    QString iconPath = QDir::currentPath() + "/icons/icon.png";
    if (QFile::exists(iconPath))
        w.setWindowIcon(QIcon(iconPath));
    w.show();
    
    return a.exec();
}
