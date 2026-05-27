import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:juris_honoris/app.dart';
import 'package:juris_honoris/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await initDependencies();

  runApp(const JurisHonorisApp());
}
