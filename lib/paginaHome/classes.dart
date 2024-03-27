class FoodItem {
  final String name;
  double calories; // por 100g
  double protein; // por 100g
  double carbs; // por 100g
  double fats; // por 100g
  double quantity; // Quantidade em gramas do alimento

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.quantity = 100, // Valor padrão de 100g, pode ser ajustado
  });

  // Método para ajustar os valores nutricionais baseado na quantidade
  void adjustForQuantity() {
    // Ajusta os valores nutricionais para a quantidade especificada
    double factor = quantity / 100;
    calories *= factor;
    protein *= factor;
    carbs *= factor;
    fats *= factor;
  }
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

class FoodItemWithQuantity {
  FoodItem foodItem;
  double quantity;

  FoodItemWithQuantity({required this.foodItem, required this.quantity});
}

class MealGoal {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  MealGoal({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
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