#!/bin/bash

echo "Backup container started..."

while true; do
    echo "[`date`] Running database backup..."
    /usr/local/bin/backup.sh
    echo "[`date`] Backup complete. Sleeping for 24h..."
    sleep 86400  # 24 horas
done
