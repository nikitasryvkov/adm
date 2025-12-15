@echo off
echo ============================================
echo Building Microservices Project
echo ============================================

echo.
echo [1/5] Building events-contract...
cd events-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build events-contract
    exit /b 1
)
cd ..

echo.
echo [2/5] Building books-api-contract...
cd books-api-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build books-api-contract
    exit /b 1
)
cd ..

echo.
echo [3/5] Building demo-rest...
cd demo-rest
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build demo-rest
    exit /b 1
)
cd ..

echo.
echo [4/5] Building analytics-service...
cd analytics-service
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build analytics-service
    exit /b 1
)
cd ..

echo.
echo [5/5] Building audit-service and ws...
cd audit-service
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build audit-service
    exit /b 1
)
cd ..

cd ws
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build ws
    exit /b 1
)
cd ..

echo.
echo [6/6] Building Docker images...
docker-compose build

echo.
echo ============================================
echo Build completed successfully!
echo ============================================
echo.
echo To start all services, run: start.bat
echo.
echo Access points:
echo   - Demo REST API:     http://localhost:8080
echo   - Swagger UI:        http://localhost:8080/swagger-ui.html
echo   - RabbitMQ Console:  http://localhost:15672
echo   - Zipkin:            http://localhost:9411
echo   - Prometheus:        http://localhost:9090
echo   - Grafana:           http://localhost:3000 (admin/admin)
echo   - Jenkins:           http://localhost:8085
