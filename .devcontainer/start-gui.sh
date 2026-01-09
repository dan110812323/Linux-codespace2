#!/bin/bash
# start-gui.sh - Inicia KDE Plasma com noVNC (versão corrigida 2026)

set -e

echo "Iniciando KDE Plasma com noVNC..."

# Variáveis configuráveis
RESOLUTION="1920x1080"   # Ajuste aqui se quiser menor (ex: 1280x720)
DEPTH=24
VNC_PORT=5901
NOVNC_PORT=6080

# Limpa sessões antigas para evitar conflitos/grey screen
echo "Limpando sessões VNC antigas..."
vncserver -kill :1 2>/dev/null || true
pkill -f websockify 2>/dev/null || true
pkill -f Xvnc 2>/dev/null || true   # Tigervnc usa Xvnc internamente

# Cria/atualiza xstartup com fixes para KDE (evita grey/black screen)
echo "Configurando xstartup para KDE Plasma..."
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
xsetroot -solid '#2E3440'  # Fundo cinza-azulado agradável
vncconfig -iconic &        # Ativa clipboard compartilhado
exec dbus-launch --exit-with-session startplasma-x11
EOF

chmod +x ~/.vnc/xstartup

# Verifica se a senha VNC existe (criada no post-create.sh)
if [ ! -f ~/.vnc/passwd ]; then
  echo "Erro: Arquivo de senha VNC não encontrado! Rode o post-create.sh novamente."
  exit 1
fi

# Inicia TigerVNC com a senha pré-criada
echo "Iniciando servidor VNC (TigerVNC)..."
vncserver :1 \
  -geometry $RESOLUTION \
  -depth $DEPTH \
  -alwaysshared \
  -rfbauth ~/.vnc/passwd \
  -rfbport $VNC_PORT \
  -fp /usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1

# Inicia websockify + noVNC (porta 6080)
echo "Iniciando bridge noVNC na porta 6080..."
websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$VNC_PORT &

echo ""
echo "===================================================="
echo "KDE Plasma iniciado com sucesso!"
echo "Acesse agora:"
echo "1. Aba PORTS (no topo do Codespaces)"
echo "2. Porta 6080 → Clique direito → Make Public (se necessário)"
echo "3. Clique no ícone de globo ao lado da porta 6080"
echo "4. Abra o link no navegador do celular → Connect → senha: mudeessaenha"
echo "(ou a senha que você definiu no post-create.sh)"
echo ""
echo "Dicas de debug:"
echo "- Ver logs VNC: tail -n 50 ~/.vnc/*.log"
echo "- Se grey/black screen: vncserver -kill :1 && ./start-gui.sh"
echo "- Para parar tudo: vncserver -kill :1 && pkill websockify"
echo "===================================================="

# Mantém o container vivo
tail -f /dev/null
