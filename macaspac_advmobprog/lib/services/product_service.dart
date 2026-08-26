import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$host/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productsData = data['products'] ?? [];
      return productsData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getProductById(int productId) async {
    final response = await http.get(Uri.parse('$host/products/$productId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return Product.fromJson(data);
      }
      throw const FormatException('Product data is invalid');
    } else {
      throw Exception('Failed to load product $productId');
    }
  }
}
