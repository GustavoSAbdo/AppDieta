import 'package:hive/hive.dart';

part 'hive_food_item.g.dart'; // Nome do arquivo gerado pelo Hive

@HiveType(typeId: 0)
class HiveFoodItem {
  @HiveField(0)
  final String name;
  @HiveField(1)
  double calories;
  @HiveField(2)
  double protein;
  @HiveField(3)
  double carbs;
  @HiveField(4)
  double fats;
  @HiveField(5)
  double quantity;
  @HiveField(6)
  String dominantNutrient;

  HiveFoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.quantity = 100,
    this.dominantNutrient = '',
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