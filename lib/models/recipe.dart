class Recipe {
  String id;
  String name;
  double coffeeRatio;
  double sugarRatio;
  double milkRatio;
  double totalWeight;
  bool isDefault;

  Recipe({
    required this.id,
    required this.name,
    required this.coffeeRatio,
    required this.sugarRatio,
    required this.milkRatio,
    required this.totalWeight,
    this.isDefault = false,
  });

  Recipe copyWith({
    String? id,
    String? name,
    double? coffeeRatio,
    double? sugarRatio,
    double? milkRatio,
    double? totalWeight,
    bool? isDefault,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      coffeeRatio: coffeeRatio ?? this.coffeeRatio,
      sugarRatio: sugarRatio ?? this.sugarRatio,
      milkRatio: milkRatio ?? this.milkRatio,
      totalWeight: totalWeight ?? this.totalWeight,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
