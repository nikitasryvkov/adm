@echo off
echo ============================================
echo Сборка микросервисного проекта
echo ============================================

echo.
echo [1/5] Сборка events-contract...
cd events-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать events-contract
    exit /b 1
)
cd ..

echo.
echo [2/5] Сборка books-api-contract...
cd books-api-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать books-api-contract
    exit /b 1
)
cd ..

echo.
echo [3/5] Сборка demo-rest...
cd demo-rest
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать demo-rest
    exit /b 1
)
cd ..

echo.
echo [4/5] Сборка analytics-service...
cd analytics-service
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать analytics-service
    exit /b 1
)
cd ..

echo.
echo [5/5] Сборка audit-service и ws...
cd audit-service
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать audit-service
    exit /b 1
)
cd ..

cd ws
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать ws
    exit /b 1
)
cd ..

echo.
echo [6/6] Сборка Docker-образов...
docker-compose build

echo.
echo ============================================
echo Сборка успешно завершена!
echo ============================================
echo.
echo Для запуска всех сервисов выполните: start.bat
echo.
echo Точки доступа:
echo   - Demo REST API:     http://localhost:8080
echo   - Swagger UI:        http://localhost:8080/swagger-ui.html
echo   - RabbitMQ Console:  http://localhost:15672
echo   - Zipkin:            http://localhost:9411
echo   - Prometheus:        http://localhost:9090
echo   - Grafana:           http://localhost:3000 (admin/admin)
echo   - Jenkins:           http://localhost:8085
