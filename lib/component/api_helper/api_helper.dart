import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../web_desktop_common/collection/collection_modal.dart';
import '../../web_desktop_common/privacy_policy/privacy_policy_modal.dart';
import '../../web_desktop_common/sale/sale_modal.dart';
import '../../web_desktop_common/shipping_policy/ShippingPolicyModal.dart';
import '../product_details/product_details_modal.dart';

class ApiHelper {
  static const String baseUrl = "https://www.kireimics.com/apis/";
  static const String baseUrlF = "https://www.kireimics.com/apis/frontend/";
  static const String baseUrlC = "https://www.kireimics.com/apis/common/";
  static const String baseUrlB = "https://www.kireimics.com/apis/backend/";

  // Fetch data from API

  static Future<Map<String, dynamic>?> fetchGeneralLinks() async {
    final response = await http.get(
      Uri.parse("$baseUrlC/general_links/get_general_links.php"),
    );

    if (response.statusCode == 200) {
      // print(jsonDecode(response.body)[0]);
      return jsonDecode(response.body)[0];
    } else {
      // print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchContactData() async {
    final response = await http.get(
      Uri.parse("$baseUrlC/contact/get_contact.php"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)[0];
    } else {
      // print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserData(String email) async {
    final response = await http.get(
      Uri.parse("$baseUrlC/user_data/get_user_data.php?email=$email"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<ShippingPolicyModel?> fetchShippingPolicy() async {
    final url = Uri.parse("$baseUrlC/shipping_policy/get_shipping_policy.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return ShippingPolicyModel.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      // print('Error fetching shipping policy: $e');
      return null;
    }
  }

  static Future<PrivacyPolicyModal?> fetchPrivacyPolicy() async {
    final url = Uri.parse("$baseUrlC/privacy_policy/get_privacy_policy.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return PrivacyPolicyModal.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      // print('Error fetching privacy policy: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchProfileDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlC/get_about_us/get_about_us.php'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load profile details');
      }
    } catch (e) {
      // print('Error fetching profile details: $e');
      return null;
    }
  }

  static Future fetchFooterDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlC/footer_details/get_footer.php'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json;
      } else {
        throw Exception('Failed to load footer details');
      }
    } catch (e) {
      // print('Error fetching footer details: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchCatalogCategoriesData() async {
    final response = await http.get(Uri.parse("$baseUrlC/categories.php"));

    if (response.statusCode == 200) {
      // print(response.body);
      return jsonDecode(response.body);
    } else {
      // print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<List<dynamic>?> fetchSaleCategoriesData() async {
    final response = await http.get(
      Uri.parse("$baseUrlC/categories_data/sale_categories.php"),
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return jsonDecode(response.body);
    } else {
      // print("Error: ${response.statusCode}");
      return null;
    }
  }

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrlC/product_details/get_products_details.php"),
      );

      if (response.statusCode == 200) {
        // print(response.body);
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

  static Future<Product?> fetchProductDetailsById(int id) async {
    final url = Uri.parse(
      '${baseUrlC}product_details/get_products_details.php?id=$id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final productData = jsonResponse['data'][0];
          return Product.fromJson(productData);
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return null;
  }

  static Future<Product?> fetchProductDetailsByIdShowAll(int id) async {
    final url = Uri.parse(
      '${baseUrlC}product_details/get_products_details.php?id=$id&show_all=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final productData = jsonResponse['data'][0];
          return Product.fromJson(productData);
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return null;
  }

  // In your ApiHelper class
  static Future<List<Product>> fetchProductByCatId(int catId) async {
    final url = Uri.parse(
      '${baseUrlC}product_details/get_products_details.php?cat_id=$catId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("This is from the cat_id");
        // print(response.body);
        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic> productsData = jsonResponse['data'];
          return productsData
              .map((productData) => Product.fromJson(productData))
              .toList();
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return []; // Return empty list on failure instead of null
  }

  static Future<List<SaleModal>> fetchProductsSale() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrlC/sale/get_sale_product.php"),
      );

      if (response.statusCode == 200) {
        // print(response.body);
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['error'] == false && jsonData['data'] != null) {
          List<SaleModal> products =
              (jsonData['data'] as List)
                  .map((item) => SaleModal.fromJson(item))
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

  static Future<List<SaleModal>> fetchProductByCatIdSale(int catId) async {
    final url = Uri.parse('$baseUrlC/sale/get_sale_product.php?cat_id=$catId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("This is from the cat_id");
        // print(response.body);
        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic> productsData = jsonResponse['data'];
          return productsData
              .map((productData) => SaleModal.fromJson(productData))
              .toList();
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return []; // Return empty list on failure instead of null
  }

  static Future<List<Product>> fetchBannerProductById(int id) async {
    final url = Uri.parse(
      '${baseUrlC}collection_list/get_collection_banner.php?id=$id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("This is from the id");
        // print(response.body);
        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic> productsData = jsonResponse['data'];
          return productsData
              .map((productData) => Product.fromJson(productData))
              .toList();
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return []; // Return empty list on failure instead of null
  }

  static Future<List<Product>> fetchBannerProductByCatIdAndId(
    int id,
    int catId,
  ) async {
    final url = Uri.parse(
      '${baseUrlC}collection_list/get_collection_banner.php?id=$id&cat_id=$catId',
    );

    try {
      final response = await http.get(url);
      // print('Requesting URL: $url');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("This is from the id and cat id ");
        // print(response.body);
        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic> productsData = jsonResponse['data'];
          return productsData
              .map((productData) => Product.fromJson(productData))
              .toList();
        } else {
          // print('API Error: ${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return []; // Return empty list on failure instead of null
  }

  static Future<List<CollectionModal>> fetchCollectionBanner() async {
    final url = Uri.parse(
      '${baseUrlC}collection_list/get_collection_banner.php',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("Raw response: ${response.body}"); // Log for debugging

        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic>? collectionsData = jsonResponse['data'];
          if (collectionsData != null) {
            return collectionsData
                .map(
                  (collectionData) => CollectionModal.fromJson(
                    collectionData as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else {
            // ('Data field is null');
          }
        } else {
          // print('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return [];
  }

  static Future<List<CollectionModal>> fetchCollectionBannerSort() async {
    final url = Uri.parse(
      '${baseUrlC}collection_list/get_collection_banner_sort.php',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("Raw response: ${response.body}"); // Log for debugging

        if (jsonResponse['error'] == false && jsonResponse['data'] != null) {
          final List<dynamic>? collectionsData = jsonResponse['data'];
          if (collectionsData != null) {
            return collectionsData
                .map(
                  (collectionData) => CollectionModal.fromJson(
                    collectionData as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else {
            // print('Data field is null');
          }
        } else {
          // print('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception: $e');
    }

    return [];
  }

  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? password, // Made optional
    required String createdAt,
  }) async {
    try {
      final Map<String, String> body = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'createdAt': createdAt,
      };

      if (password != null) {
        body['password'] = password;
      }

      final response = await http.post(
        Uri.parse('${baseUrlF}login_signup/signup.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> editRegisterUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String updatedAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlF}login_signup/edit_signup.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'updated_at': updatedAt,
        },
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> passwordReset({
    required String email,
    required String password,

    required String updatedAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlF}login_signup/pasword_reset.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password, 'updated_at': updatedAt},
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateStock({
    required String productId,
    required String quantity,

    required String updatedAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlB}stock/delete_stock_by_quantity.php'),

        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'product_id': productId,
          'quantity': quantity,

          'updated_at': updatedAt,
        },
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDefaultAddress(int userId) async {
    final url =
        '${baseUrlF}user_address/get_default_address.php?created_by=$userId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load address data');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlF}login_signup/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static const String _baseUrl = 'https://api.postalpincode.in';

  /// Fetches PIN code data for the given pincode.
  /// Returns a map with 'state' and 'city' if successful.
  /// Throws an exception if the request fails or data is invalid.
  Future<Map<String, String>> fetchPincodeData(String pincode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pincode/$pincode'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffices = data[0]['PostOffice'] as List;
          if (postOffices.isNotEmpty) {
            return {
              'state': postOffices[0]['State'],
              'city': postOffices[0]['Name'],
            };
          }
        }
        throw Exception('No valid data found for the provided PIN code');
      } else {
        throw Exception(
          'Failed to fetch PIN code data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching PIN code data: $e');
    }
  }

  static Future<Map<String, dynamic>> registerAddress({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address1,
    required String address2,
    required String pinCode,
    required String state,
    required String city,
    required String defaultAddress,
    required String createdBy,
    required String createdAt,
    required String updatedAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlF}user_address/user_address.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address1': address1,
          'address2': address2,
          'pincode': pinCode,
          'state': state,
          'city': city,
          'default_address': defaultAddress,
          'created_by': createdBy,
          'created_at': createdAt,
          'updated_at': updatedAt,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> getUserAddress(String userId) async {
    final url = Uri.parse(
      '$baseUrlF/user_address/get_user_address.php?created_by=$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserAddressById(String userId) async {
    final url = Uri.parse(
      '$baseUrlF/user_address/get_address_by_id.php?id=$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUserAddress({
    required String addressId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrlF/user_address/delete_user_address.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': addressId, 'created_by': userId},
      );

      final jsonData = json.decode(response.body);
      return {'error': false, 'message': jsonData['message']};
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> editUserAddress({
    required String addressId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address1,
    required String address2,
    required String pinCode,
    required String state,
    required String city,
    required String defaultAddress,
    required String createdBy,
    required String updatedAt,
  }) async {
    final url = Uri.parse('$baseUrlF/user_address/edit_user_address.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': addressId,
          'created_by': createdBy,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address1': address1,
          'address2': address2,
          'pincode': pinCode,
          'state': state,
          'city': city,
          'default_address': defaultAddress,
          'updated_at': updatedAt,
        },
      );

      final jsonData = json.decode(response.body);
      return {'error': false, 'message': jsonData['message']};
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStockDetail(String productId) async {
    final url = Uri.parse(
      '$baseUrlC/get_stock/get_stock.php?product_id=$productId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> orderPurchaseDetails({
    required String userId,
    required String productDetails,
    required String orderId,
    required String isSuccess,
    required String paymentMode,
    required String paymentId,
    required String amount,
    required String razorpayAmount,
    required String shippingTaxes,
    required String itemTotal,
    required String addressId,
    required String createdAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlB}order_payments_details/insert_order_payment.php'),

        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId,
          'product_details': productDetails,
          'order_id': orderId,
          'is_success': isSuccess,
          'payment_mode': paymentMode,
          'payment_id': paymentId,
          'amount': amount,
          'razorpay_amount': razorpayAmount,
          'shipping_taxes': shippingTaxes,
          'item_total': itemTotal,
          'address_id': addressId,
          'created_at': createdAt,
        },
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(String userId) async {
    final url = Uri.parse(
      '$baseUrlC/order_details/get_order_details.php?user_id=$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        // print(jsonData);
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetailsByOrderId(
    String orderId,
  ) async {
    final url = Uri.parse(
      '$baseUrlC/order_details/get_order_details.php?order_id=$orderId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        // print(jsonData);
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  // Inside ApiHelper class
  static Future<Map<String, dynamic>> getShippingTax(
    Map<String, String> params,
  ) async {
    final url = Uri.parse(
      '${baseUrlF}order_created/shipping_taxes.php',
    ).replace(queryParameters: params);

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['error'] == false) {
        return {'error': false, 'data': jsonData['data']};
      } else {
        return {
          'error': true,
          'message':
              jsonData['message'] ?? jsonData['data'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> orderCreate({
    required String orderId,
    required String orderDate,
    required String billingCustomerName,
    required String billingLastName,
    required String billingAddress,
    required String billingCity,
    required String billingPincode,
    required String billingState,
    required String billingCountry,
    required String billingEmail,
    required String billingPhone,
    required List<Map<String, dynamic>> orderItems,
    required String paymentMethod,
    required String subTotal,
    required String length,
    required String breadth,
    required String height,
    required String weight,
  }) async {
    try {
      final body = {
        'order_id': orderId,
        'order_date': orderDate,
        'billing_customer_name': billingCustomerName,
        'billing_last_name': billingLastName,
        'billing_address': billingAddress,
        'billing_city': billingCity,
        'billing_pincode': billingPincode,
        'billing_state': billingState,
        'billing_country': billingCountry,
        'billing_email': billingEmail,
        'billing_phone': billingPhone,
        'shipping_is_billing': true,
        'order_items': orderItems,
        'payment_method': paymentMethod,
        'sub_total': double.parse(subTotal),
        'length': double.parse(length),
        'breadth': double.parse(breadth),
        'height': double.parse(height),
        'weight': double.parse(weight),
      };

      final response = await http.post(
        Uri.parse('${baseUrlF}order_created/order_created.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> awbCodeDetails({
    required String awbCode,
  }) async {
    try {
      final body = {'awb_code': awbCode};

      final response = await http.post(
        Uri.parse('${baseUrlF}order_created/track_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> registerMail({
    required String email,
  }) async {
    try {
      // print("Sending registerMail for email: $email"); // ADD THIS LINE

      final Map<String, String> body = {'email': email};

      final response = await http.post(
        Uri.parse('${baseUrl}email_templates/signup_email.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordMail({
    required String email,
  }) async {
    try {
      // print("Sending registerMail for email: $email"); // ADD THIS LINE

      final Map<String, String> body = {'email': email};

      final response = await http.post(
        Uri.parse('${baseUrl}email_templates/reset_password.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordSuccessfullyMail({
    required String email,
  }) async {
    try {
      // print("Sending registerMail for email: $email"); // ADD THIS LINE

      final Map<String, String> body = {'email': email};

      final response = await http.post(
        Uri.parse('${baseUrl}email_templates/password_updated.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> orderCreatedMail({
    required String email,
    required String orderId,
    required String name,
    required String placedOn,
    required String totalAmount,
  }) async {
    try {
      // print("Sending registerMail for email: $email"); // ADD THIS LINE

      final Map<String, String> body = {
        'email': email,
        'order_id': orderId,
        'name': name,
        'total_amount': totalAmount,
        'placed_on': placedOn,
      };

      final response = await http.post(
        Uri.parse('${baseUrl}email_templates/order_created.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'error': true,
          'message': '${json.decode(response.body)['message']}',
        };
      }
    } catch (e) {
      return {'error': true, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> contactQuery({
    required String name,
    required String email,
    required String message,

    required String createdAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlB}contact/insert_contact_us_query.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'email': email,
          'message': message,

          'created_at': createdAt,
        },
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> notifyQuery({
    required String pId,
    required String email,
    required String createdAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrlC}notify_user/insert_notify_user.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'product_id': pId, 'email': email, 'created_at': createdAt},
      );

      // print("HTTP Status Code: ${response.statusCode}");
      // print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'error': true,
            'message': 'Invalid JSON response: ${response.body}',
          };
        }
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // print("API call error: $e");
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<void> fetchAndPrintProductsByIds(List<String> ids) async {
    final idString = ids.join(',');
    final url = Uri.parse(
      "$baseUrlC/product_details/get_checkout_product_details.php?id=$idString",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      if (jsonBody['error'] == false && jsonBody['data'] != null) {
        final List data = jsonBody['data'];

        for (var item in data) {
          // print('Name: ${item['name']}');
          // print('Height: ${item['height']}');
          // print('Breadth: ${item['breadth']}');
          // print('Weight: ${item['weight']}');
          // print('---');
        }
      } else {
        throw Exception(jsonBody['message'] ?? "Unknown error");
      }
    } else {
      throw Exception("Failed to fetch products: ${response.statusCode}");
    }
  }
}
