// Menambah izin lokasi + nama app "RunOS" ke folder android/ios hasil `flutter create`.
import 'dart:io';

void main() {
  final man = File('android/app/src/main/AndroidManifest.xml');
  if (man.existsSync()) {
    var s = man.readAsStringSync();
    if (!s.contains('ACCESS_FINE_LOCATION')) {
      s = s.replaceFirst('<application',
          '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>\n    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>\n    <uses-permission android:name="android.permission.WAKE_LOCK"/>\n    <application');
    }
    s = s.replaceFirst(RegExp(r'android:label="[^"]*"'), 'android:label="RunOS"');
    man.writeAsStringSync(s);
    stdout.writeln('Android: izin lokasi + nama app OK');
  }
  final plist = File('ios/Runner/Info.plist');
  if (plist.existsSync()) {
    var s = plist.readAsStringSync();
    if (!s.contains('NSLocationWhenInUseUsageDescription')) {
      s = s.replaceFirst(
          RegExp(r'</dict>\s*</plist>'),
          '\t<key>NSLocationWhenInUseUsageDescription</key>\n\t<string>RunOS memakai lokasi untuk melacak rute dan jarak larimu.</string>\n</dict>\n</plist>');
    }
    s = s.replaceFirstMapped(
        RegExp(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*'), (m) => '${m[1]}RunOS');
    plist.writeAsStringSync(s);
    stdout.writeln('iOS: izin lokasi + nama app OK');
  }
}
