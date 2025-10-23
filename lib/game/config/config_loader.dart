import 'dart:convert';
import 'package:flutter/services.dart';
import 'balance_config.dart';
import 'wave_config.dart';

class ConfigLoader {
  static BalanceConfig? _balance;
  static WaveConfig? _wave;

  static BalanceConfig get balance {
    if (_balance == null) {
      throw Exception('Balance config not loaded. Call loadConfigs() first.');
    }
    return _balance!;
  }

  static WaveConfig get wave {
    if (_wave == null) {
      throw Exception('Wave config not loaded. Call loadConfigs() first.');
    }
    return _wave!;
  }

  static Future<void> loadConfigs() async {
    final balanceJson =
        await rootBundle.loadString('assets/config/balance.json');
    final waveJson = await rootBundle.loadString('assets/config/waves.json');

    _balance = BalanceConfig.fromJson(json.decode(balanceJson));
    _wave = WaveConfig.fromJson(json.decode(waveJson));
  }
}
