import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core.dart';
import 'screens_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF081331),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Store.i.load();
  runApp(const RunOSApp());
}

class RunOSApp extends StatelessWidget {
  const RunOSApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RunOS',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
      );
}
