#!/bin/bash
# start-gui.sh - Inicia KDE Plasma com noVNC no Codespaces (versão corrigida 2026)

set -e

echo "Iniciando KDE Plasma com noVNC..."

# Variáveis (ajuste aqui)
RESOLUTION="1920x1080"  # Melhor para ImHex e arquivos grandes
DEPTH=24
VNC_PORT=5901
NOVNC_PORT=6080
VNC_PASSWORD="mudeessaenha"  # Mude para algo forte!

# Limpa sessões antigas para evitar conflitos
vncserver -kill :1 2>/dev/null || true
pkill -f websockify 2>/dev/null || true
pkill -f Xvnc 2>/dev/null || true  # Se usar tigervnc

# Cria/atualiza xstartup (fix grey screen + clipboard)
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
xsetroot -solid '#2E3440'  # Fundo cinza-azulado
vncconfig -iconic &  # Clipboard compartilhado
exec dbus-launch --exit-with-session startplasma-x11
EOF

chmod +x ~/.vnc/xstartup

# Configura senha VNC se não existir
if [ ! -f ~/.vnc/passwd ]; then
  echo "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
  chmod 600 ~/.vnc/passwd
fi

# Inicia tigervnc (embutido X server, mais estável que Xvfb + vncserver separado)
vncserver :1 \
  -geometry $RESOLUTION \
  -depth $DEPTH \
  -alwaysshared \
  -fp /usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1 \
  -rfbport $VNC_PORT

# Inicia websockify + noVNC (porta 6080)
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_PORT &

echo ""
echo "KDE Plasma iniciado!"
echo "- Acesse via porta 6080 no browser (aba PORTS → Make Public → globo)"
echo "- Senha VNC: $VNC_PASSWORD"
echo "- Se grey screen: verifique logs com tail -n 50 ~/.vnc/*.log"
echo "- Para parar: vncserver -kill :1 && pkill websockify"
echo ""

# Mantém o processo vivo
tail -f /dev/null
