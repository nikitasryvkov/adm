@echo off
echo ============================================
echo Запуск микросервисов через Docker Compose
echo ============================================

echo.
echo Остановка существующих контейнеров...
docker-compose down --remove-orphans

echo.
echo Запуск всех сервисов...
docker-compose up -d

echo.
echo Ожидание старта сервисов...
timeout /t 30 /nobreak

echo.
echo ============================================
echo Все сервисы запущены!
echo ============================================
echo.

echo Точки доступа:
echo   - Demo REST API:     http://localhost:8080
echo   - GraphQL:           http://localhost:8080/graphiql
echo   - Swagger UI:        http://localhost:8080/swagger-ui.html
echo   - WebSocket Demo:    http://localhost:8083
echo   - RabbitMQ Console:  http://localhost:15672 (guest/guest)
echo   - Zipkin Tracing:    http://localhost:9411
echo   - Prometheus:        http://localhost:9090
echo   - Grafana:           http://localhost:3000 (admin/admin)
echo   - Jenkins:           http://localhost:8085
echo.

echo Логи: docker-compose logs -f
echo Остановить все: docker-compose down
