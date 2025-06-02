import 'package:flutter/material.dart';
import '../shared_preferences/shared_preferences.dart';

class CartNotifier extends ValueNotifier<int> {
  CartNotifier() : super(0) {
    _loadInitialCount();
  }

  Future<void> _loadInitialCount() async {
    final ids = await SharedPreferencesHelper.getAllProductIds();
    value = ids.length;
  }

  Future<void> refresh() async {
    final ids = await SharedPreferencesHelper.getAllProductIds();
    value = ids.length;
  }
}

final cartNotifier = CartNotifier();
