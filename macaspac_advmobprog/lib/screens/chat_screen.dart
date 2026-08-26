import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'Chat feature is available here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
