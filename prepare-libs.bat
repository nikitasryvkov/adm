@echo off
echo ============================================
echo Подготовка общих библиотек (контракты)
echo ============================================

echo.
echo [1/2] Сборка events-contract...
cd events-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать events-contract
    exit /b 1
)
cd ..

echo.
echo [2/2] Сборка books-api-contract...
cd books-api-contract
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ОШИБКА: Не удалось собрать books-api-contract
    exit /b 1
)
cd ..

echo.
echo ============================================
echo Библиотеки успешно подготовлены!
echo ============================================
echo.
echo Далее: запустите build.bat
