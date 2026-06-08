
#deps:
sudo apt install -y qtchooser

sudo apt install qt5-default qtbase5-dev qtbase5-dev-tools qttools5-dev-tools -y

git clone https://github.com/qextserialport/qextserialport.git


// En tu código C++
#include <wiringPi.h>

// Configurar GPIO
wiringPiSetup();
pinMode(0, INPUT);  // Botón en GPIO0



#Rendimiento

# Aumentar memoria GPU en /boot/config.txt
echo "gpu_mem=256" | sudo tee -a /boot/config.txt

# Habilitar aceleración OpenGL
echo "dtoverlay=vc4-fkms-v3d" | sudo tee -a /boot/config.txt


Característica	        PC Normal	                    Raspberry Pi 4
Plataforma	                x11/wayland	                    EGLFS
Resolución	                Variable	                    800x480 fijo
Input	                    Mouse/Teclado	                Táctil
Renderizado	                Software/GL	                    OpenGL ES
Performance	                Alta	                        Optimizada


