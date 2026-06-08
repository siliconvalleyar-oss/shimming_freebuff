#include "mainwindow.hpp"
#include <QApplication>
#include <QSplashScreen>
#include <QTimer>
#include <QDebug>
#include <QIcon>
#include <QPixmap>
#include <QDir>
#include <QFile>

/*
 * ── Application entry point ───────────────────────────────────────────────────
 *
 * Responsibilities:
 *   1. Create the working directories (icons/, logs/, plots/).
 *   2. Show a splash screen with the application logo (fallback to blank).
 *   3. Launch the main window and enter the Qt event loop.
 *
 * The directories are created before the MainWindow so that FileShimming
 * can immediately write logs without additional setup.
 *
 * Splash lifetime: 500 ms (single-shot timer). If the splash needs to
 * stay visible longer (e.g. slow hardware), increase the timer interval.
 */
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // These must exist before any subsystem tries to write to them
    QDir().mkpath("icons");
    QDir().mkpath("logs");
    QDir().mkpath("plots");

    /*
     * Splash screen — graceful degradation if the image is missing:
     * the animal.png logo is a project asset but may not be present
     * during development.  A 200×200 blank pixmap prevents a crash.
     */
    QSplashScreen splash;
    const QString splashPath = QDir::currentPath() + "/icons/animal.png";
    if (QFile::exists(splashPath)) {
        splash.setPixmap(QPixmap(splashPath));
    } else {
        splash.setPixmap(QPixmap(200, 200));
        splash.showMessage("Cargando...");
    }
    splash.setWindowOpacity(0.95);
    splash.show();

    // Auto-close after 500 ms regardless of load time
    QTimer::singleShot(500, &splash, &QSplashScreen::close);

    MainWindow window;

    /*
     * Application icon — also degrades gracefully.
     * icon.png is optional; without it the OS provides a default.
     */
    const QString iconPath = QDir::currentPath() + "/icons/icon.png";
    if (QFile::exists(iconPath))
        window.setWindowIcon(QIcon(iconPath));

    window.show();

    return app.exec();
}
