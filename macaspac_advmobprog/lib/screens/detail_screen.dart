import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

class DetailScreen extends StatefulWidget {
  final int productId;

  const DetailScreen({super.key, required this.productId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CustomText(
                  text: 'Unable to load product details.\n${snapshot.error}',
                  fontSize: 14.sp,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final product = snapshot.data;
          if (product == null) {
            return const Center(child: Text('Product not found.'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    product.thumbnail,
                    width: double.infinity,
                    height: 260.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 260.h,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image, size: 42.sp),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                CustomText(
                  text: product.title,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 6.w),
                    CustomText(
                      text: '${product.rating} / 5',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: '\$${product.price.toStringAsFixed(2)} each',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    CustomText(
                      text: 'Quantity',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          CustomText(
                            text: '$_quantity',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: 'Total: \$${(product.price * _quantity).toStringAsFixed(2)}',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                SizedBox(height: 6.h),
                CustomText(
                  text: 'Brand: ${product.brand}',
                  fontSize: 14.sp,
                ),
                SizedBox(height: 6.h),
                CustomText(
                  text: 'Stock: ${product.stock}',
                  fontSize: 14.sp,
                ),
                SizedBox(height: 18.h),
                CustomText(
                  text: 'Description',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: product.description,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 18.h),
                if (product.images.isNotEmpty)
                  SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.images.length,
                      separatorBuilder: (context, index) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        final image = product.images[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            image,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) => Container(
                              width: 100.w,
                              height: 100.h,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image, size: 28.sp),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await CartService().addToCart(
                          userId: cartUserId,
                          productId: product.id,
                          quantity: _quantity,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} ($_quantity) added to cart'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Add to cart failed: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart'),
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
