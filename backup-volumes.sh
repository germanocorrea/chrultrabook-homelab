#!/usr/bin/env bash

REMOTE_HOST=$1
DEST_DIR=$2

if [ -z "$REMOTE_HOST" ] || [ -z "$DEST_DIR" ]; then
    echo "Uso: $0 usuario@ip diretorio_destino"
    exit 1
fi

mkdir -p "$DEST_DIR"

# Configurar SSH Multiplexing para pedir senha apenas uma vez
SSH_OPTS="-o ControlMaster=auto -o ControlPath=/tmp/ssh-%r@%h:%p -o ControlPersist=60"

echo "--- Iniciando backup de volumes de $REMOTE_HOST ---"

VOLUMES=$(ssh $SSH_OPTS "$REMOTE_HOST" "podman volume ls -q")

for VOL in $VOLUMES; do
    echo "-> Exportando: $VOL..."
    ssh $SSH_OPTS "$REMOTE_HOST" "podman volume export $VOL --output -" >"$DEST_DIR/$VOL.tar"
done

# Fechar a conexão mestre
ssh $SSH_OPTS -O exit "$REMOTE_HOST" 2>/dev/null

echo "--- Backup concluído em $DEST_DIR ---"
