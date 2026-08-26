import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // LAB ACTIVITY 4 - ENHANCEMENT 1:
  // This splash screen reads saved session data and redirects authenticated
  // users directly to the home screen while new users are sent to sign in.
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final user = await UserService().getSavedUser();

    if (!mounted) return;

    if (user != null && user.id > 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Image.asset(
                  'assets/icons/nubdexchange_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              'Bulldogs Exchange',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Loading your account...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: 180.w,
              child: LinearProgressIndicator(
                minHeight: 6.h,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
