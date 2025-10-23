import 'package:flutter/foundation.dart';
import '../config/config_loader.dart';

class ResourceManager extends ChangeNotifier {
  int _money = 200; // Default starting values
  int _energy = 20;
  double _agiPercent = 5.0;
  bool _isPowerOk = true;
  int _negativeEnergyStartTime = 0;

  int get money => _money;
  int get energy => _energy;
  double get agiPercent => _agiPercent;
  bool get isPowerOk => _isPowerOk;

  void initialize() {
    final config = ConfigLoader.balance;
    _money = config.economy.startMoney;
    _energy = config.economy.startEnergy;
    _agiPercent = config.agi.startPercent;
    _isPowerOk = true;
    notifyListeners();
  }

  bool canAfford(int cost) => _money >= cost;

  void spendMoney(int amount) {
    _money -= amount;
    notifyListeners();
  }

  void addMoney(int amount) {
    _money += amount;
    notifyListeners();
  }

  void addEnergy(int amount) {
    _energy += amount;
    notifyListeners();
  }

  void removeEnergy(int amount) {
    _energy -= amount;
    notifyListeners();
  }

  void addAgi(double amount) {
    _agiPercent += amount;
    notifyListeners();
  }

  void removeAgi(double amount) {
    _agiPercent -= amount;
    notifyListeners();
  }

  void checkPowerStatus(int currentTime) {
    final config = ConfigLoader.balance;

    if (_energy < 0) {
      if (_isPowerOk) {
        _negativeEnergyStartTime = currentTime;
        _isPowerOk = false;
      } else {
        // Check if grace period has expired
        if (currentTime - _negativeEnergyStartTime >
            config.economy.outageGraceMs) {
          // Brownout active
        }
      }
    } else {
      _isPowerOk = true;
      _negativeEnergyStartTime = 0;
    }
    notifyListeners();
  }

  bool hasWon() {
    return _agiPercent >= ConfigLoader.balance.agi.winPercent;
  }

  bool hasLost() {
    return _agiPercent <= ConfigLoader.balance.agi.lossPercent;
  }

  void reset() {
    initialize();
  }
}
