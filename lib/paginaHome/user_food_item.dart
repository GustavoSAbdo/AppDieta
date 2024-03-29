import 'package:hive/hive.dart';

part 'user_food_item.g.dart'; // Nome do arquivo gerado pelo Hive

@HiveType(typeId: 1)
class FoodItem {
  @HiveField(0)
  final String name;
  @HiveField(1)
  double calories; // por 100g
  @HiveField(2)
  double protein; // por 100g
  @HiveField(3)
  double carbs; // por 100g
  @HiveField(4)
  double fats; // por 100g
  @HiveField(5)
  double quantity;
  @HiveField(6)
  String dominantNutrient; // Quantidade em gramas do alimento

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.quantity = 100,
    required this.dominantNutrient // Valor padrão de 100g, pode ser ajustado
  });

   Map<String, dynamic> toMap() {
    return {
      'nome': name,
      'kcal': calories,
      'proteina': protein,
      'carboidrato': carbs,
      'gordura': fats,
      'dominantNutrient': dominantNutrient,
    };
  }
}