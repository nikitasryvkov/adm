@echo off
echo ============================================
echo Stopping Microservices
echo ============================================

docker-compose down --remove-orphans

echo.
echo All services stopped.

