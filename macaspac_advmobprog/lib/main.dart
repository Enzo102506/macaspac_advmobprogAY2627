import 'package:flutter/material.dart';

// App entry point: launches the application.
void main() => runApp(const StateManagementActivity());

class StateManagementActivity extends StatefulWidget {
  const StateManagementActivity({super.key});

  // Root widget that holds app-level theme state and provides MaterialApp.
  @override
  State<StateManagementActivity> createState() =>
      _StateManagementActivityState();
}

class _StateManagementActivityState extends State<StateManagementActivity> {
  ThemeMode _themeMode = ThemeMode.system;

  // Show a bottom sheet allowing the user to select Light/Dark/System theme.
  void _showThemePicker(BuildContext parentContext) {
    showModalBottomSheet<void>(
      context: parentContext,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: const Text('Dark Mode'),
            trailing: Builder(
              builder: (switchContext) {
                // Determine whether dark is effectively enabled (respecting System).
                final platformDark =
                    MediaQuery.of(parentContext).platformBrightness ==
                    Brightness.dark;
                final isDarkEffective =
                    _themeMode == ThemeMode.dark ||
                    (_themeMode == ThemeMode.system && platformDark);

                return Switch.adaptive(
                  value: isDarkEffective,
                  onChanged: (v) {
                    setState(() {
                      _themeMode = v ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Open the full Settings page where users can toggle theme options.
  void _openSettingsPage(BuildContext parentContext) {
    Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (ctx) => SettingsPage(
          currentMode: _themeMode,
          onModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Build the MaterialApp using the chosen `ThemeMode`.
      title: 'Ephemeral',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: const MyHomePage(),
    );
  }
}

// Settings page that allows toggling dark mode.
class SettingsPage extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const SettingsPage({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final platformDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final isDarkEffective =
        currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system && platformDark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Dark Mode'),
            value: isDarkEffective,
            onChanged: (v) {
              onModeChanged(v ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // Create the mutable state for the home page.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;

  void _incrementCounter() {
    // Increment the visible counter and trigger a rebuild.
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Build the UI for the home page (app bar, body, FAB).
      appBar: AppBar(
        title: const Text('Ephemeral'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              final state = context
                  .findAncestorStateOfType<_StateManagementActivityState>();
              // Open the dedicated Settings page.
              state?._openSettingsPage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
