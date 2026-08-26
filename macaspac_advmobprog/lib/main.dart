// packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

// screens
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';

// providers
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) async {
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e) {
      debugPrint('Warning: .env file not found: $e');
    }
    runApp(const MacaspacAdvMobProg());
  });
}

class MacaspacAdvMobProg extends StatelessWidget {
  const MacaspacAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'E-Commerce App',
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/signin': (context) => const SignInScreen(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/cart': (context) => CartScreen(userId: cartUserId),
            },
          );
        },
      ),
    );
  }
}
