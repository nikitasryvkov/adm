@echo off
echo ============================================
echo Starting Microservices with Docker Compose
echo ============================================

echo.
echo Stopping existing containers...
docker-compose down --remove-orphans

echo.
echo Starting all services...
docker-compose up -d

echo.
echo Waiting for services to start...
timeout /t 30 /nobreak

echo.
echo ============================================
echo All services started!
echo ============================================
echo.
echo Access points:
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
echo To view logs: docker-compose logs -f
echo To stop all: docker-compose down
