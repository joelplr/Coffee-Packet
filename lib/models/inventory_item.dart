class InventoryItem {
  String name;
  double quantity;
  String unit;
  double maxCapacity;
  double lowThreshold;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.maxCapacity,
    required this.lowThreshold,
  });

  double get percentFull => (quantity / maxCapacity).clamp(0.0, 1.0);
  bool get isLow => quantity <= lowThreshold;
  bool get isEmpty => quantity <= 0;
}
