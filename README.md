# shimming

Aplicación Qt5 para shimming de resonancia magnética mediante puerto serie.

## Compilación

```bash
qmake shimming.pro
make
```

Los objetos compilados se alojan en `obj/`.

## Dependencias

```bash
sudo apt install -y qtbase5-dev qtbase5-dev-tools qttools5-dev-tools qt5-qmake libqt5serialport5-dev
```

## Compilación cruzada para Raspberry Pi (aarch64)

El proyecto es compatible con Raspberry Pi (ARM64). Todos los archivos fuente compilan correctamente con `aarch64-linux-gnu-g++`.

```bash
# Opción 1: Cross-compile con paquetes arm64 (multi-arch)
sudo dpkg --add-architecture arm64
sudo apt update
sudo apt install -y qtbase5-dev:arm64 libqt5serialport5-dev:arm64
qmake -spec linux-aarch64-gnu-g++ shimming.pro
make

# Opción 2: Usar script de cross-compilación
./scripts/cross-compile.sh
```

## Estructura del proyecto

```
├── include/        # Headers (.hpp)
├── src/            # Código fuente (.cpp)
├── obj/            # Objetos compilados (.o) — ignorado por git
├── icons/          # Assets gráficos
├── scripts/        # Scripts de utilidad
├── .opencode/      # Skill del proyecto
├── shimming.pro    # Archivo de proyecto Qt
└── README.md
```

## Problemas de compilación resueltos

El proyecto no compilaba por dos razones:

1. **`shimming.pro` tenía rutas incorrectas** — los archivos fuente están en `src/` y los headers en `include/`, pero el `.pro` los referenciaba sin prefijo de directorio. Se corrigió agregando `src/`, `include/` y `INCLUDEPATH += include`.

2. **`scripts/install_deps.sh` instalaba la librería incorrecta** — usaba `libqextserialport-dev` (librería externa obsoleta) en lugar de `libqt5serialport5-dev` (el módulo oficial de Qt SerialPort que requiere `QT += serialport`). El script fue corregido.

## Raspberry Pi (notas adicionales)

Dependencias para compilar directamente en Raspberry Pi:

```bash
sudo apt install -y qtbase5-dev libqt5serialport5-dev wiringpi
```

Configuración de GPIO y GPU para Raspberry Pi:

```bash
echo "gpu_mem=256" | sudo tee -a /boot/config.txt
echo "dtoverlay=vc4-fkms-v3d" | sudo tee -a /boot/config.txt
```

La aplicación usa EGLFS como plataforma de renderizado en Raspberry Pi, con resolución 800x480 y entrada táctil.
