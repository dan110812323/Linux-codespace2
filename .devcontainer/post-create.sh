#!/bin/bash
# post-create.sh - Instalação completa KDE Plasma + VNC/noVNC + Ren'Py para Codespaces

set -e  # Para se der erro, parar o script

echo "Iniciando instalação automática KDE Plasma + VNC + Ren'Py..."

# Atualiza sistema
sudo apt update -y && sudo apt upgrade -y

# Instala KDE Plasma (leve) + VNC/noVNC + ferramentas essenciais
sudo apt install -y \
  kde-plasma-desktop task-kde-desktop \
  tigervnc-standalone-server tigervnc-common \
  novnc websockify dbus-x11 \
  firefox-esr kate dolphin konsole \
  p7zip-full unrar rar wget unzip tar procps

# Instala Ren'Py SDK (versão mais recente em jan/2026 – ajuste se precisar de outra)
cd /home/vscode
wget https://www.renpy.org/dl/8.3.7/renpy-8.3.7-sdk.tar.bz2 -O renpy.tar.bz2
tar -xjf renpy.tar.bz2
mv renpy-8.3.7-sdk renpy-sdk
rm renpy.tar.bz2
chmod +x renpy-sdk/renpy.sh

# Configura senha VNC (mude aqui para algo forte!)
VNC_PASSWORD="mudeessaenha"  # <--- ALTERE AQUI !!!
mkdir -p ~/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Cria xstartup corrigido para KDE (evita grey/black screen)
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
xsetroot -solid '#2E3440'  # Fundo cinza-azulado
vncconfig -iconic &
exec dbus-launch --exit-with-session startplasma-x11
EOF

chmod +x ~/.vnc/xstartup

# Limpa cache para economizar espaço
sudo apt clean && sudo rm -rf /var/lib/apt/lists/*

echo ""
echo "===================================================="
echo "Instalação completa!"
echo "- KDE Plasma instalado (use startplasma-x11)"
echo "- Ren'Py SDK em ~/renpy-sdk (rode ./renpy-sdk/renpy.sh)"
echo "- VNC senha: $VNC_PASSWORD (mude no script!)"
echo "- Acesse via porta 6080 no browser (iniciado pelo start-gui.sh)"
echo ""
echo "Se der tela cinza ao conectar:"
echo "   vncserver -kill :1 && vncserver :1 -geometry 1920x1080 -depth 24"
echo "===================================================="
