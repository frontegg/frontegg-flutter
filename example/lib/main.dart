import 'package:flutter/material.dart';
import 'package:frontegg/frontegg.dart';
import 'package:provider/provider.dart';

import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Provider(
        create: (_) => FronteggFlutter(),
        dispose: (_, frontegg) => frontegg.dispose(),
        child: const MainPage(),
      ),
    );
  }
}
