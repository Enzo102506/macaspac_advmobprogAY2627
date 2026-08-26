import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  bool _isLoading = false;

  // LAB ACTIVITY 4 - ENHANCEMENT 2:
  // The sign-in UI authenticates users through the UserService and stores the
  // returned user session for later splash-screen reuse.
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService().login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6B4BB2);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 18.h),
                  Container(
                    width: 92.w,
                    height: 92.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: purple, width: 3),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18.w),
                      child: Image.asset(
                        'assets/icons/nubdexchange_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sign in to continue to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  SizedBox(
                    width: 330.w,
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person_outline, color: purple),
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: purple, width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: 330.w,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock_outline, color: purple),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: purple, width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 330.w,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _signIn,
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: _isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        _isLoading ? 'Signing in...' : 'Sign In',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    width: 330.w,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Demo account: emilys / emilyspass',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
