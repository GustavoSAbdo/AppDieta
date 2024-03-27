class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  FoodItem({required this.name, required this.calories, required this.protein, required this.carbs, required this.fats});

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['nome'] as String,
      calories: (map['kcal'] as num?)?.toDouble() ?? 0.0, // Convertendo para double e tratando null
      protein: (map['proteina'] as num?)?.toDouble() ?? 0.0, // Convertendo para double e tratando null
      carbs: (map['carboidrato'] as num?)?.toDouble() ?? 0.0, // Convertendo para double e tratando null
      fats: (map['gordura'] as num?)?.toDouble() ?? 0.0, // Convertendo para double e tratando null
    );
  }
}

class Refeicao {
  
  List<FoodItem> items;

  Refeicao({List<FoodItem>? items})
    : items = items ?? [];

  double getTotalCalories(double totalDayCalories, int numRef) => totalDayCalories / numRef;
  double getTotalProtein(double totalDayProtein, int numRef) => totalDayProtein / numRef;
  double getTotalCarbs(double totalDayCarbs, int numRef) => totalDayCarbs / numRef;
  double getTotalFats(double totalDayFats, int numRef) => totalDayFats / numRef;

  // Adiciona um item de comida à refeição
  void addFoodItem(FoodItem item) {
    items.add(item);
  }

  // Remove um item de comida da refeição
  void removeFoodItem(FoodItem item) {
    items.remove(item);
  }  
}