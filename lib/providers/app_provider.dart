import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/inventory_item.dart';
import '../models/production_log.dart';
import '../models/notification_item.dart';

enum MachineStatus { idle, running, paused, error }
enum NavPage { dashboard, recipes, machineControl, inventory, analytics, settings }

class AppProvider extends ChangeNotifier {
  NavPage _currentPage = NavPage.dashboard;
  MachineStatus _machineStatus = MachineStatus.idle;
  Timer? _productionTimer;
  int _totalSachetsProduced = 0;
  int _currentRate = 0;
  double _productionSpeed = 60; // packets/min
  double _sachetSize = 20; // grams
  double _sealingTemp = 180; // celsius
  Recipe? _activeRecipe;
  String _currentUser = 'Admin User';
  String _currentRole = 'Admin';

  final List<Recipe> _recipes = [
    Recipe(id: '1', name: 'Classic Blend', coffeeRatio: 40, sugarRatio: 35, milkRatio: 25, totalWeight: 20, isDefault: true),
    Recipe(id: '2', name: 'Strong Black', coffeeRatio: 70, sugarRatio: 15, milkRatio: 15, totalWeight: 20),
    Recipe(id: '3', name: 'Sweet Latte', coffeeRatio: 30, sugarRatio: 40, milkRatio: 30, totalWeight: 25),
    Recipe(id: '4', name: 'Mocha Delight', coffeeRatio: 50, sugarRatio: 30, milkRatio: 20, totalWeight: 22),
  ];

  final List<InventoryItem> _inventory = [
    InventoryItem(name: 'Coffee Powder', quantity: 45.5, unit: 'kg', maxCapacity: 100, lowThreshold: 20),
    InventoryItem(name: 'Sugar', quantity: 18.2, unit: 'kg', maxCapacity: 80, lowThreshold: 15),
    InventoryItem(name: 'Milk Powder', quantity: 32.0, unit: 'kg', maxCapacity: 60, lowThreshold: 10),
  ];

  final List<ProductionLog> _productionLogs = [];
  final List<NotificationItem> _notifications = [];

  // Daily production data for chart (last 7 days)
  final List<double> _weeklyProduction = [1200, 1450, 980, 1680, 1320, 1560, 0];
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  AppProvider() {
    _activeRecipe = _recipes.firstWhere((r) => r.isDefault);
    _generateInitialLogs();
    _notifications.add(NotificationItem(
      title: 'System Ready',
      message: 'Coffee Machine Platform initialized successfully.',
      type: NotificationType.info,
      timestamp: DateTime.now(),
    ));
  }

  void _generateInitialLogs() {
    final rng = Random();
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final count = _weeklyProduction[6 - i].toInt();
      if (count > 0) {
        _productionLogs.add(ProductionLog(
          recipeId: _recipes[rng.nextInt(_recipes.length)].id,
          recipeName: _recipes[rng.nextInt(_recipes.length)].name,
          quantity: count,
          timestamp: day,
        ));
        _totalSachetsProduced += count;
      }
    }
  }

  // Getters
  NavPage get currentPage => _currentPage;
  MachineStatus get machineStatus => _machineStatus;
  int get totalSachetsProduced => _totalSachetsProduced;
  int get currentRate => _currentRate;
  double get productionSpeed => _productionSpeed;
  double get sachetSize => _sachetSize;
  double get sealingTemp => _sealingTemp;
  Recipe? get activeRecipe => _activeRecipe;
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<ProductionLog> get productionLogs => List.unmodifiable(_productionLogs);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  String get currentUser => _currentUser;
  String get currentRole => _currentRole;
  List<double> get weeklyProduction => List.unmodifiable(_weeklyProduction);
  List<String> get weekDays => List.unmodifiable(_weekDays);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String get machineStatusLabel {
    switch (_machineStatus) {
      case MachineStatus.idle: return 'Idle';
      case MachineStatus.running: return 'Running';
      case MachineStatus.paused: return 'Paused';
      case MachineStatus.error: return 'Error';
    }
  }

  void navigate(NavPage page) {
    _currentPage = page;
    notifyListeners();
  }

  void startMachine() {
    if (_machineStatus == MachineStatus.error) return;
    _machineStatus = MachineStatus.running;
    _currentRate = (_productionSpeed / 1).round();
    _productionTimer?.cancel();
    _productionTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      final produced = max(1, (_productionSpeed / 30).round());
      _totalSachetsProduced += produced;
      _weeklyProduction[6] += produced.toDouble();
      _consumeInventory(produced);
      notifyListeners();
    });
    _addNotification('Machine Started', 'Production started with recipe: ${_activeRecipe?.name}', NotificationType.success);
    notifyListeners();
  }

  void stopMachine() {
    _machineStatus = MachineStatus.idle;
    _currentRate = 0;
    _productionTimer?.cancel();
    if (_totalSachetsProduced > 0) {
      _productionLogs.add(ProductionLog(
        recipeId: _activeRecipe?.id ?? '',
        recipeName: _activeRecipe?.name ?? 'Unknown',
        quantity: _totalSachetsProduced,
        timestamp: DateTime.now(),
      ));
    }
    _addNotification('Machine Stopped', 'Production stopped. Total today: ${_weeklyProduction[6].toInt()} sachets.', NotificationType.info);
    notifyListeners();
  }

  void pauseMachine() {
    if (_machineStatus == MachineStatus.running) {
      _machineStatus = MachineStatus.paused;
      _currentRate = 0;
      _productionTimer?.cancel();
      _addNotification('Machine Paused', 'Production has been paused.', NotificationType.warning);
      notifyListeners();
    } else if (_machineStatus == MachineStatus.paused) {
      startMachine();
    }
  }

  void _consumeInventory(int produced) {
    if (_activeRecipe == null) return;
    final totalGrams = produced * _sachetSize;
    for (var item in _inventory) {
      double ratio = 0;
      if (item.name == 'Coffee Powder') ratio = _activeRecipe!.coffeeRatio / 100;
      if (item.name == 'Sugar') ratio = _activeRecipe!.sugarRatio / 100;
      if (item.name == 'Milk Powder') ratio = _activeRecipe!.milkRatio / 100;
      item.quantity -= (totalGrams * ratio) / 1000;
      if (item.quantity < item.lowThreshold && item.quantity > 0) {
        _addNotification('Low Stock Alert', '${item.name} is running low: ${item.quantity.toStringAsFixed(1)} ${item.unit} remaining.', NotificationType.warning);
      }
      if (item.quantity <= 0) {
        item.quantity = 0;
        _machineStatus = MachineStatus.error;
        _productionTimer?.cancel();
        _addNotification('Machine Error', '${item.name} is out of stock! Production halted.', NotificationType.error);
      }
    }
  }

  void setProductionSpeed(double value) {
    _productionSpeed = value;
    notifyListeners();
  }

  void setSachetSize(double value) {
    _sachetSize = value;
    notifyListeners();
  }

  void setSealingTemp(double value) {
    _sealingTemp = value;
    notifyListeners();
  }

  void setActiveRecipe(Recipe recipe) {
    _activeRecipe = recipe;
    notifyListeners();
  }

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  void updateRecipe(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      notifyListeners();
    }
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void setDefaultRecipe(String id) {
    for (var r in _recipes) {
      r.isDefault = r.id == id;
    }
    notifyListeners();
  }

  void restockInventory(String name, double amount) {
    final item = _inventory.firstWhere((i) => i.name == name);
    item.quantity = (item.quantity + amount).clamp(0, item.maxCapacity);
    if (_machineStatus == MachineStatus.error) {
      final hasError = _inventory.any((i) => i.quantity <= 0);
      if (!hasError) _machineStatus = MachineStatus.idle;
    }
    _addNotification('Inventory Restocked', '${item.name} restocked to ${item.quantity.toStringAsFixed(1)} ${item.unit}.', NotificationType.success);
    notifyListeners();
  }

  void _addNotification(String title, String message, NotificationType type) {
    _notifications.insert(0, NotificationItem(
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    ));
    if (_notifications.length > 50) _notifications.removeLast();
  }

  void markAllRead() {
    for (var n in _notifications) n.isRead = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _productionTimer?.cancel();
    super.dispose();
  }
}
