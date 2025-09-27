class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final double? budgetLimit;
  final bool isDefault;

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.color = '#6366F1',
    this.budgetLimit,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'budgetLimit': budgetLimit,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'] ?? '#6366F1',
      budgetLimit: map['budgetLimit'],
      isDefault: map['isDefault'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    double? budgetLimit,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}