import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentStateService {
  static final PaymentStateService _instance = PaymentStateService._internal();

  factory PaymentStateService() => _instance;

  PaymentStateService._internal();

  static const _storageKey = 'payment_result';

  Future<void> setPaymentResult({
    required bool success,
    required String orderId,
    required double amount,
    required DateTime orderDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'success': success,
      'orderId': orderId,
      'amount': amount,
      'orderDate': orderDate.toIso8601String(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getPaymentResult() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      data['orderDate'] = DateTime.parse(data['orderDate']);
      return data;
    } catch (e) {
      // print('Error decoding payment result: $e');
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
