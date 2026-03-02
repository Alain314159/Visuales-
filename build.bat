@echo off
REM Visuales UCLV - Build and Development Script (Windows)
REM This script helps with common development and build tasks

setlocal enabledelayedexpansion

REM Colors (Windows 10+)
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
  set "COLOR=%%b"
)

set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

:menu
cls
echo ========================================
echo   Visuales UCLV - Build Menu
echo ========================================
echo.
echo   1. Setup (Check Flutter + Dependencies)
echo   2. Run Tests
echo   3. Analyze Code
echo   4. Clean Build
echo   5. Build Debug APK
echo   6. Build Release APK
echo   7. Build App Bundle
echo   8. Run App
echo   9. Complete Build (All)
echo   0. Exit
echo.
set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto test
if "%choice%"=="3" goto analyze
if "%choice%"=="4" goto clean
if "%choice%"=="5" goto debug
if "%choice%"=="6" goto release
if "%choice%"=="7" goto bundle
if "%choice%"=="8" goto run
if "%choice%"=="9" goto all
if "%choice%"=="0" goto end
goto menu

:setup
echo.
echo ========================================
echo   Setting Up Project
echo ========================================
call flutter --version
if errorlevel 1 (
    echo.
    echo ERROR: Flutter is not installed. Please install Flutter first.
    echo Visit: https://docs.flutter.dev/get-started/install
    pause
    goto menu
)
call flutter pub get
echo.
echo Setup complete!
pause
goto menu

:test
echo.
echo ========================================
echo   Running Tests
echo ========================================
call flutter test
if errorlevel 1 (
    echo.
    echo ERROR: Tests failed
    pause
    goto menu
)
echo.
echo All tests passed!
pause
goto menu

:analyze
echo.
echo ========================================
echo   Analyzing Code
echo ========================================
call flutter analyze
if errorlevel 1 (
    echo.
    echo ERROR: Analysis found issues
    pause
    goto menu
)
echo.
echo No issues found!
pause
goto menu

:clean
echo.
echo ========================================
echo   Cleaning Build
echo ========================================
call flutter clean
call flutter pub get
echo.
echo Build cleaned!
pause
goto menu

:debug
echo.
echo ========================================
echo   Building Debug APK
echo ========================================
call flutter build apk --debug
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    pause
    goto menu
)
echo.
echo Debug APK built: build\app\outputs\flutter-apk\app-debug.apk
pause
goto menu

:release
echo.
echo ========================================
echo   Building Release APK
echo ========================================
call flutter pub get
call flutter build apk --release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    pause
    goto menu
)
echo.
echo Release APK built: build\app\outputs\flutter-apk\app-release.apk
pause
goto menu

:bundle
echo.
echo ========================================
echo   Building App Bundle
echo ========================================
call flutter pub get
call flutter build appbundle --release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    pause
    goto menu
)
echo.
echo App Bundle built: build\app\outputs\bundle\release\app-release.aab
pause
goto menu

:run
echo.
echo ========================================
echo   Running App
echo ========================================
call flutter pub get
call flutter run
goto menu

:all
echo.
echo ========================================
echo   Complete Build Process
echo ========================================
call flutter --version
if errorlevel 1 (
    echo.
    echo ERROR: Flutter is not installed
    pause
    goto menu
)
call flutter pub get
call flutter test
if errorlevel 1 (
    echo.
    echo ERROR: Tests failed
    pause
    goto menu
)
call flutter analyze
if errorlevel 1 (
    echo.
    echo ERROR: Analysis found issues
    pause
    goto menu
)
call flutter build apk --release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    pause
    goto menu
)
echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo APK location: build\app\outputs\flutter-apk\app-release.apk
pause
goto menu

:end
echo.
echo Goodbye!
exit /b 0
