import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App entry point for the widget test app: provides ThemeModel and runs MyApp.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build the top-level MaterialApp using the current theme from ThemeModel.
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MyHome(),
    );
  }
}

class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  // Return whether dark theme is enabled.
  bool get isDark => _isDark;

  // Toggle the theme and notify listeners to rebuild UI.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  // Build the home screen with an app bar switch to toggle theme.
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Example'),
        actions: [
          Switch(
            value: themeModel.isDark,
            onChanged: (_) => themeModel.toggleTheme(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Toggle the theme using the switch in the app bar'),
      ),
    );
  }
}
