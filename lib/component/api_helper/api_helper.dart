import 'dart:convert';
import 'package:http/http.dart' as http;

import '../product_details/product_details_modal.dart';

class ApiHelper {
  static const String baseUrl = "https://vedvika.com/v1/apis/";

  // Fetch data from API
  static Future<Map<String, dynamic>?> fetchContactData() async {
    final response = await http.get(Uri.parse("$baseUrl/Contact.php"));

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      )[0]; // Assuming it's a list with one object
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<List<dynamic>?> fetchCategoriesData() async {
    final response = await http.get(Uri.parse("$baseUrl/categories.php"));

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_products_details.php"),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['error'] == false && jsonData['data'] != null) {
          List<Product> products =
              (jsonData['data'] as List)
                  .map((item) => Product.fromJson(item))
                  .toList();
          return products;
        } else {
          throw Exception('Failed to load products: ${jsonData['message']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<Product?> fetchProductById(int id) async {
    final url = Uri.parse('${baseUrl}get_product_details_by_id.php?id=$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final productData = jsonResponse['data'][0];
          return Product.fromJson(productData);
        } else {
          print('API Error: ${jsonResponse['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }

    return null;
  }
}
