#!/usr/bin/env bash
set -euo pipefail

echo "============================================"
echo "Сборка микросервисов"
echo "============================================"

# 1. Контракты
echo
echo "[1/6] Сборка events-contract..."
( cd events-contract && chmod +x ./mvnw && ./mvnw clean install -DskipTests )

echo
echo "[2/6] Сборка books-api-contract..."
( cd books-api-contract && chmod +x ./mvnw && ./mvnw clean install -DskipTests )

# 2. Сервисы
echo
echo "[3/6] Сборка demo-rest..."
( cd demo-rest && chmod +x ./mvnw && ./mvnw clean package -DskipTests )

echo
echo "[4/6] Сборка analytics-service..."
( cd analytics-service && chmod +x ./mvnw && ./mvnw clean package -DskipTests )

echo
echo "[5/6] Сборка audit-service..."
( cd audit-service && chmod +x ./mvnw && ./mvnw clean package -DskipTests )

echo
echo "[6/6] Сборка ws (notification-service)..."
( cd ws && chmod +x ./mvnw && ./mvnw clean package -DskipTests )

echo
echo "============================================"
echo "Сборка Docker-образов (если нужно)"
echo "============================================"
echo "Подсказка: docker compose build"
echo
echo "Готово. Чтобы запустить сервисы: start.sh"

