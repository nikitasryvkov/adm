#!/usr/bin/env bash
set -euo pipefail

echo "============================================"
echo "Подготовка общих библиотек (контракты)"
echo "============================================"

echo
echo "[1/2] Сборка events-contract..."
(
  cd events-contract
  chmod +x ./mvnw
  ./mvnw clean install -DskipTests
)

echo
echo "[2/2] Сборка books-api-contract..."
(
  cd books-api-contract
  chmod +x ./mvnw
  ./mvnw clean install -DskipTests
)

echo
echo "============================================"
echo "Библиотеки успешно подготовлены!"
echo "============================================"
echo
echo "Далее: запустите build.sh"

