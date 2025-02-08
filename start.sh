#!/bin/bash

sudo apt update && sudo apt install -y tmux
echo "Instalando Playit y tmux..."
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install -y playit tmux

# 2. Obtener la ruta del secret
SECRET_PATH=$(playit secret-path | awk '{print $NF}')
echo "Ruta del archivo secret: $SECRET_PATH"

# 3. Escribir el secret key en el archivo
SECRET_KEY="76ee958292ae59516910e1e24256563a731073175c47a993816a398ca8f38173"
echo "$SECRET_KEY" | sudo tee "$SECRET_PATH" > /dev/null
echo "Secret key guardado correctamente."

# 4. Iniciar Playit en una sesión de tmux
echo "Iniciando Playit en una sesión separada..."
tmux new-session -d -s playit_session "playit"

# 5. Esperar unos segundos para asegurar que Playit esté funcionando
sleep 5

# 6. Iniciar el servidor de Minecraft en otra sesión de tmux
echo "Iniciando el servidor de Minecraft en una sesión separada..."
tmux new-session -d -s minecraft_session "java -Xms10G -Xmx16G -jar paper-1.21.4-138.jar --nogui"

echo "Todo está en marcha 🚀"

# 7. Determinar qué archivo de configuración de shell usar
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    echo "No se encontró un archivo de configuración de shell compatible."
    exit 1
fi

# 8. Agregar los alias al archivo de configuración del shell si no existen
if ! grep -q "alias /minecraft=" "$SHELL_CONFIG"; then
    echo "Agregando alias a $SHELL_CONFIG..."
    cat <<EOF >> "$SHELL_CONFIG"

# Alias para adjuntar la sesión de Minecraft
alias minecraft="tmux attach-session -t minecraft_session"

# Alias para adjuntar la sesión de Playit
alias playit="tmux attach-session -t playit_session"

# Alias para ver las sesiones activas
alias tmux-list="tmux list-sessions"
EOF
    echo "Alias añadidos correctamente."
fi

# 9. Recargar configuración del shell
echo "Recargando configuración del shell..."
source "$SHELL_CONFIG"

echo "¡Configuración completa! Usa /minecraft o /playit para acceder a las sesiones."
