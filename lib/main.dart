import 'package:flutter/material.dart';

import 'core/app.dart';
import 'local_storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage().init();

  runApp(const MyApp());
}
