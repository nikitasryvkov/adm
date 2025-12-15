@echo off
echo ============================================
echo Preparing Local Libraries for Docker Build
echo ============================================

echo.
echo [1/2] Building and installing events-contract...
cd events-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build events-contract
    exit /b 1
)
cd ..

echo.
echo [2/2] Building and installing books-api-contract...
cd books-api-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build books-api-contract
    exit /b 1
)
cd ..

echo.
echo ============================================
echo Libraries prepared successfully!
echo ============================================
echo.
echo Now run: build.bat
