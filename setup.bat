@echo off
title RunOS Setup
echo ==== RunOS setup (Flutter) ====
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter tidak ditemukan di PATH.
  pause
  exit /b 1
)
if not exist android (
  call flutter create --project-name runos --org com.skyy --platforms=android,ios .
)
if exist test\widget_test.dart del /q test\widget_test.dart
call flutter pub get
call dart run flutter_launcher_icons
call dart tool\patch_platform.dart
echo.
echo Selesai! Jalankan: flutter run
echo Build APK: flutter build apk --release
pause
