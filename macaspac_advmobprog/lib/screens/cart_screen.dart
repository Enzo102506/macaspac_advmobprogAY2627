import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  // Enhancement 1: Cart screen displays the user's cart and allows
  // cart products to navigate to the existing product detail screen.
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<Cart> _loadCart() {
    return CartService().getCartByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _cartFuture = _loadCart();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CustomText(
                  text: 'Unable to load cart data.\n${snapshot.error}',
                  fontSize: 14.sp,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CustomText(
                  text: 'Your cart is empty right now.',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final totalPrice = cart.products.fold<double>(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _cartFuture = _loadCart();
              });
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: cart.products.length,
                    itemBuilder: (context, index) {
                      final product = cart.products[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                product.thumbnail,
                                width: 58.w,
                                height: 58.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 58.w,
                                  height: 58.h,
                                  color: Colors.grey.withValues(alpha: 0.12),
                                  child: Icon(Icons.image, size: 24.sp),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomText(
                                    text: '${product.quantity} item${product.quantity > 1 ? 's' : ''}',
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Row(
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 28.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB9A5F3),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        final updatedQuantity = product.quantity + 1;
                                        cart.products[index] = CartProduct(
                                          id: product.id,
                                          title: product.title,
                                          price: product.price,
                                          quantity: updatedQuantity,
                                          total: product.price * updatedQuantity,
                                          discountPercentage: product.discountPercentage,
                                          discountedTotal: product.discountedTotal,
                                          thumbnail: product.thumbnail,
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                CustomText(
                                  text: '${product.quantity}',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  width: 28.w,
                                  height: 28.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB9A5F3),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (product.quantity > 1) {
                                        setState(() {
                                          final updatedQuantity = product.quantity - 1;
                                          cart.products[index] = CartProduct(
                                            id: product.id,
                                            title: product.title,
                                            price: product.price,
                                            quantity: updatedQuantity,
                                            total: product.price * updatedQuantity,
                                            discountPercentage: product.discountPercentage,
                                            discountedTotal: product.discountedTotal,
                                            thumbnail: product.thumbnail,
                                          );
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Total',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        text: '\$${totalPrice.toStringAsFixed(2)}',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
