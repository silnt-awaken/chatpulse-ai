import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError =
      (details) => log(details.exceptionAsString(), stackTrace: details.stack);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(await builder());
}
