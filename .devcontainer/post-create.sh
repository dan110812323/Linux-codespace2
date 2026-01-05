#!/bin/bash
# Atualiza e instala KDE Plasma, VNC/noVNC, Ren'Py, 7-Zip, Firefox, etc.
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y kde-plasma-desktop task-kde-desktop tigervnc-standalone-server tigervnc-common novnc websockify dbus-x11 procps firefox p7zip-full kate dolphin wget tar

# Instala Ren'Py SDK (latest versão)
cd /home/vscode
wget https://www.renpy.org/dl/8.3.7/renpy-8.3.7-sdk.tar.bz2
tar -xjf renpy-8.3.7-sdk.tar.bz2
mv renpy-8.3.7-sdk renpy-sdk
rm renpy-8.3.7-sdk.tar.bz2

# Configura VNC senha (mude pra algo forte)
echo "mudeessaenha" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Pronto! Mensagem no terminal
echo "Instalação completa! KDE Plasma, Ren'Py em ~/renpy-sdk, 7-Zip, Firefox etc. prontos."
