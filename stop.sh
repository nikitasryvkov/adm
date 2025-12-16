#!/usr/bin/env bash
set -euo pipefail

echo "============================================"
echo "Остановка микросервисов"
echo "============================================"

docker compose down --remove-orphans || true

echo
echo "Все сервисы остановлены."

