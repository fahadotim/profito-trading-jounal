import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trade.dart';

/// Persists trades and the starting account balance on-device using
/// SharedPreferences. No network, no account needed — everything stays
/// on this phone/computer.
class StorageService {
  static const _tradesKey = 'trades_v1';
  static const _startingBalanceKey = 'starting_balance_v1';

  Future<List<Trade>> loadTrades() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tradesKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Trade.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTrades(List<Trade> trades) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(trades.map((t) => t.toJson()).toList());
    await prefs.setString(_tradesKey, encoded);
  }

  Future<double> loadStartingBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_startingBalanceKey) ?? 10.0;
  }

  Future<void> saveStartingBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_startingBalanceKey, balance);
  }
}
