#!/bin/bash
# Inicia KDE Plasma com noVNC
export DISPLAY=:1
export RESOLUTION=1024x768x24  # Ajuste se quiser (ex: 1280x720x24)

Xvfb :1 -screen 0 $RESOLUTION &
sleep 2
dbus-launch startplasma-x11 &
vncserver :1 -geometry ${RESOLUTION%??} -depth ${RESOLUTION##*x} -passwd ~/.vnc/passwd -rfbport 5901 -fp /usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1 &
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

echo "noVNC rodando! Abra porta 6080/vnc.html no navegador."
tail -f /dev/null
