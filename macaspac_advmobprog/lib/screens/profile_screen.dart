import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/user.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User?> _loadUser() async {
    return UserService().getUserData();
  }

  Future<Cart> _loadCartForUser(User user) async {
    return CartService().getCartByUserId(user.id);
  }

  Future<void> _updateUsername(User user) async {
    final controller = TextEditingController(text: user.username);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update username'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;

    try {
      await UserService().updateUsername(controller.text);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmedController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change password'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: confirmedController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;

    try {
      final current = currentController.text.trim();
      final newPass = newController.text.trim();
      final confirm = confirmedController.text.trim();

      if (newPass.isEmpty || newPass.length < 6) {
        throw Exception('New password must be at least 6 characters.');
      }

      if (newPass != confirm) {
        throw Exception('New passwords do not match.');
      }

      await UserService().resetPasswordFromCurrentPassword(
        currentPassword: current,
        newPassword: newPass,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteAccount(User user) async {
    final controller = TextEditingController();
    final navigator = Navigator.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This will permanently delete ${user.email}.', style: const TextStyle(fontSize: 15)),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Enter your password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;

    try {
      await UserService().deleteAccount(password: controller.text);
      if (!mounted) return;
      await UserService().logout();
      navigator.pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    try {
      await UserService().logout();
      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _loadUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_rounded, size: 56.sp, color: Colors.grey),
                  SizedBox(height: 14.h),
                  Text(
                    'No active profile found.',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sign in again to continue.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return FutureBuilder<Cart>(
          future: _loadCartForUser(user),
          builder: (context, cartSnapshot) {
            if (cartSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cart = cartSnapshot.data;
            final totalPrice = cart?.products.fold<double>(
                      0,
                      (sum, item) => sum + (item.price * item.quantity),
                    ) ??
                    0.0;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6D5EF7), Color(0xFFA66CFF)],
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34.r,
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          backgroundImage: user.image.isNotEmpty ? NetworkImage(user.image) : null,
                          child: user.image.isEmpty
                              ? Icon(Icons.person, size: 38.sp, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: user.fullName.isNotEmpty ? user.fullName : user.username,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4.h),
                              CustomText(
                                text: '@${user.username}',
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Account Details',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 12.h),
                        _infoRow('User ID', '#${user.id}'),
                        _infoRow('Email', user.email),
                        _infoRow('Gender', user.gender.isNotEmpty ? user.gender : 'Not specified'),
                        _infoRow('Token', user.token.isNotEmpty ? 'Active' : 'Not available'),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Account Actions',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 12.h),
                        _actionButton(
                          label: 'Update Username',
                          icon: Icons.edit,
                          onPressed: () => _updateUsername(user),
                        ),
                        SizedBox(height: 8.h),
                        _actionButton(
                          label: 'Change Password',
                          icon: Icons.lock_reset,
                          onPressed: _changePassword,
                        ),
                        SizedBox(height: 8.h),
                        _actionButton(
                          label: 'Delete Account',
                          icon: Icons.delete_forever,
                          color: Colors.red,
                          onPressed: () => _deleteAccount(user),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'My Cart',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomText(
                              text: 'User #${user.id}',
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (cart == null || cart.products.isEmpty)
                          Text(
                            'Your cart is empty.',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                          )
                        else ...[
                          ...cart.products.take(3).map((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Divider(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estimated total', style: TextStyle(fontSize: 13.sp)),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.deepPurple,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
