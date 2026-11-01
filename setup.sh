#!/usr/bin/env bash
set -e
echo "==== RunOS setup (Flutter) ===="
command -v flutter >/dev/null || { echo "Flutter tidak ditemukan di PATH"; exit 1; }
[ -d android ] || flutter create --project-name runos --org com.skyy --platforms=android,ios .
rm -f test/widget_test.dart
flutter pub get
dart run flutter_launcher_icons
dart tool/patch_platform.dart
echo "Selesai! Jalankan: flutter run"
