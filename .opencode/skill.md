# shimming

Qt5 application for MRI shimming via serial port.

## Build (native)

```bash
sudo apt install -y build-essential g++ qtbase5-dev qtbase5-dev-tools qttools5-dev-tools qt5-qmake libqt5serialport5-dev
qmake shimming.pro
make
```

## Cross-compilation (Raspberry Pi aarch64)

The project compiles cleanly with `aarch64-linux-gnu-g++` — all source files verified.

### Option 1: arm64 Qt5 packages (if host has arm64 multi-arch)

```bash
sudo dpkg --add-architecture arm64
sudo apt update
sudo apt install -y qtbase5-dev:arm64 libqt5serialport5-dev:arm64
qmake -spec linux-aarch64-gnu-g++ shimming.pro
make
```

### Option 2: Raspberry Pi OS sysroot

```bash
# On Raspberry Pi, rsync Qt5 libs and headers:
rsync -avz /usr/lib/aarch64-linux-gnu/qt5/ user@host:/path/to/sysroot/usr/lib/aarch64-linux-gnu/qt5/
rsync -avz /usr/include/aarch64-linux-gnu/qt5/ user@host:/path/to/sysroot/usr/include/aarch64-linux-gnu/qt5/

# On host:
export SYSROOT=/path/to/sysroot
./scripts/cross-compile.sh
```

### Option 3: Build directly on Raspberry Pi

```bash
sudo apt install -y qtbase5-dev libqt5serialport5-dev
qmake shimming.pro
make
```

## Structure

- `src/` — source files (`.cpp`)
- `include/` — headers (`.hpp`)
- `obj/` — compiled object files (`.o`), gitignored
- `icons/` — icon assets
- `scripts/` — utility scripts including `cross-compile.sh`
- `qextserialport/` — external dependency (cloned repo, not tracked)
- `build-cross/` — cross-compilation build directory

## Dependencies

- Qt5 Core, Gui, Widgets, SerialPort, PrintSupport
- `libqt5serialport5-dev` (not `libqextserialport-dev`)

## Serial Port

Configures `/dev/ttyUSB0` at 2400 baud, 8N1. Connect button toggles the port.

## UI — Tabs

| Tab | Buttons |
|-----|---------|
| Connect | Connect (serial port toggle) |
| Shimming | RECORD, PUT Frecuency, Load File, save, GET, PDF |
| Config | Create File, Close File |

- **Load File**: opens a `.txt`/`.log` file into the editor
- **PDF**: exports editor content to PDF via `QTextDocument` + `QPrinter`
- **save**: writes editor content to the active log file

## Architecture

- `MainWindow` — UI orchestration (does NOT inherit business-logic classes)
- `TableShimming` — data-driven measurement protocol (no hardcoded switch/if)
- `RS232` — serial port with configurable `PortConfig` struct
- `FileShimming` / `FileHandler` — RAII file I/O
