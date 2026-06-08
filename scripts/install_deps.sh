#!/bin/bash

# Ubuntu/Debian dependencies for shimming project
# Requires Qt5 SerialPort module (not libqextserialport-dev)

sudo apt update

# Build essentials
sudo apt install -y build-essential g++

# Qt5 base
sudo apt install -y qtbase5-dev qtbase5-dev-tools qttools5-dev-tools qt5-qmake

# Qt5 SerialPort module (required by QT += serialport in .pro file)
sudo apt install -y libqt5serialport5-dev

# Optional: Qt Charts (if needed in future)
# sudo apt install -y libqt5charts5-dev
