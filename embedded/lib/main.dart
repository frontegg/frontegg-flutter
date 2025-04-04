import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:frontegg_flutter_embedded_example/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// MyApp
///
/// This is the main app that is used to run the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Wrap the MainPage with the FronteggProvider to Frontegg SDK access
      home: FronteggProvider(
        child: const MainPage(),
      ),
    );
  }
}
