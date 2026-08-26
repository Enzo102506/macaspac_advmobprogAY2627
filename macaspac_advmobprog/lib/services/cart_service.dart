import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  static const int defaultUserId = 1;

  // Enhancement 3: Retrieve the cart using the selected user's ID.
  Future<Cart> getCartByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$host/carts/user/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final carts = data['carts'];
          if (carts is List && carts.isNotEmpty) {
            return Cart.fromJson(carts.first as Map<String, dynamic>);
          }

          if (data.isNotEmpty) {
            return Cart.fromJson(data);
          }
        }

        if (data is List && data.isNotEmpty) {
          return Cart.fromJson(data.first as Map<String, dynamic>);
        }

        return Cart(
          id: 0,
          products: const [],
          total: 0.0,
          discountedTotal: 0.0,
          userId: userId,
          totalProducts: 0,
          totalQuantity: 0,
        );
      }

      throw Exception('Failed to load cart for user $userId');
    } catch (e) {
      throw Exception('Unable to retrieve cart data: $e');
    }
  }

  // Enhancement 3: Add a product to the cart through the DummyJSON endpoint.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$host/carts/add'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'products': [
            {'id': productId, 'quantity': quantity},
          ],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return Cart.fromJson(data);
        }

        throw const FormatException('Add to cart response was invalid.');
      }

      throw Exception('Failed to add product $productId to cart');
    } catch (e) {
      throw Exception('Unable to add product to cart: $e');
    }
  }
}
