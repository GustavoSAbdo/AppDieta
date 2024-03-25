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


class ListItem {
  final String name;
  final String description;

  ListItem({required this.name, required this.description});
}

class ListGroup {
  final String title;
  final List<ListItem> items;

  ListGroup({required this.title, required this.items});
}

class Refeicao {
  
  List<FoodItem> items;

  Refeicao({List<FoodItem>? items})
    : items = items ?? [];

  // Adiciona um item de comida à refeição
  void addFoodItem(FoodItem item) {
    items.add(item);
  }

  // Remove um item de comida da refeição
  void removeFoodItem(FoodItem item) {
    items.remove(item);
  }

  // Calcula o total de calorias da refeição
  double getTotalCalories() {
    return items.fold(0, (total, item) => total + item.calories);
  }

  // Calcula o total de proteínas da refeição
  double getTotalProtein() {
    return items.fold(0, (total, item) => total + item.protein);
  }

  // Calcula o total de carboidratos da refeição
  double getTotalCarbs() {
    return items.fold(0, (total, item) => total + item.carbs);
  }

  // Calcula o total de gorduras da refeição
  double getTotalFats() {
    return items.fold(0, (total, item) => total + item.fats);
  }
}