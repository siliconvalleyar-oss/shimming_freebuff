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

- Qt5 Core, Gui, Widgets, SerialPort
- `libqt5serialport5-dev` (not `libqextserialport-dev`)

## Serial Port

Configures `/dev/ttyUSB0` at 2400 baud, 8N1. Connect button toggles the port.
