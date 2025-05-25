import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/models/product.dart';

const String baseUrl = 'http://10.0.2.2:8000';

class ApiService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product');
    }
  }

  static Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<double> calculateTotal(String name, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calculate-by-name/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"name": name, "quantity": quantity}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_price'];
    } else {
      throw Exception('Calculation failed');
    }
  }
}
