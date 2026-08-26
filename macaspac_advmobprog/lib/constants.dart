import 'package:flutter_dotenv/flutter_dotenv.dart';

final String host = dotenv.env['HOST'] ?? 'https://dummyjson.com';
final int cartUserId = int.tryParse(dotenv.env['CART_USER_ID'] ?? '') ?? 1;
