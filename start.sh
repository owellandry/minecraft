#!/bin/bash

echo "Deteniendo las sesiones de tmux..."
tmux kill-session -t playit_session 2>/dev/null

tmux kill-session -t minecraft_session 2>/dev/null

echo "Eliminando Playit y tmux..."
sudo apt remove --purge -y playit tmux
sudo rm -f /etc/apt/trusted.gpg.d/playit.gpg
sudo rm -f /etc/apt/sources.list.d/playit-cloud.list
sudo apt update

# Buscar y eliminar el archivo del secret key
SECRET_PATH=$(playit secret-path 2>/dev/null | awk '{print $NF}')
if [ -f "$SECRET_PATH" ]; then
    echo "Eliminando archivo de secret key..."
    sudo rm -f "$SECRET_PATH"
fi

# Determinar qué archivo de configuración de shell usar
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

# Eliminar los alias si el archivo de configuración existe
if [ -n "$SHELL_CONFIG" ]; then
    echo "Eliminando alias del archivo de configuración..."
    sed -i '/# Alias para adjuntar la sesión de Minecraft/d' "$SHELL_CONFIG"
    sed -i '/alias minecraft="tmux attach-session -t minecraft_session"/d' "$SHELL_CONFIG"
    sed -i '/# Alias para adjuntar la sesión de Playit/d' "$SHELL_CONFIG"
    sed -i '/alias playit="tmux attach-session -t playit_session"/d' "$SHELL_CONFIG"
    sed -i '/# Alias para ver las sesiones activas/d' "$SHELL_CONFIG"
    sed -i '/alias tmux-list="tmux list-sessions"/d' "$SHELL_CONFIG"
fi

# Recargar configuración del shell
echo "Recargando configuración del shell..."
source "$SHELL_CONFIG"

echo "Proceso de reversión completado ✅"
