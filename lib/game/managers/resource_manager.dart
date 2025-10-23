import 'package:flutter/foundation.dart';
import '../config/config_loader.dart';

class ResourceManager extends ChangeNotifier {
  int _money = 200; // Default starting values
  int _energyBudget = 20;
  int _energyReserved = 0;
  double _agiPercent = 5.0;
  bool _isPowerOk = true;
  int _overBudgetStartTime = 0;

  int get money => _money;
  int get energyBudget => _energyBudget;
  int get energyReserved => _energyReserved;
  double get agiPercent => _agiPercent;
  bool get isPowerOk => _isPowerOk;

  void initialize() {
    final config = ConfigLoader.balance;
    _money = config.economy.startMoney;
    _energyBudget = config.economy.baseEnergyBudget;
    _energyReserved = 0;
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

  void setEnergyBudget(int budget) {
    _energyBudget = budget;
    notifyListeners();
  }

  void setEnergyReserved(int reserved) {
    _energyReserved = reserved;
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

    if (_energyReserved > _energyBudget) {
      if (_isPowerOk) {
        _overBudgetStartTime = currentTime;
        _isPowerOk = false;
      } else {
        // Check if grace period has expired
        if (currentTime - _overBudgetStartTime > config.economy.outageGraceMs) {
          // Brownout active
        }
      }
    } else {
      _isPowerOk = true;
      _overBudgetStartTime = 0;
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
