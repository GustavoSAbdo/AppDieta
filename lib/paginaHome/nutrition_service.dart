import 'package:complete/paginaHome/classes.dart';

class NutritionService {
  MealGoal calculateNutritionalGoals(Map<String, dynamic> userData) {
    double peso = userData['peso'] is double
        ? userData['peso']
        : double.tryParse(userData['peso'].toString()) ?? 0;
    String objetivo = userData['objetivo'];
    String nivelAtividade = userData['nivelAtividade'];
    double coeficiente = objetivo == 'perderPeso'
        ? 0.8
        : objetivo == 'ganharPeso'
            ? 1.2
            : 1;
    double tmb = double.tryParse(userData['tmb'].toString()) ?? 0;

    double totalFats = peso * 1;
    double totalCalories;
    double totalProtein;
    double totalCarbs;

    switch (nivelAtividade) {
      case 'sedentario':
        totalCalories = tmb * coeficiente;
        break;
      case 'atividadeLeve':
        totalCalories = tmb * 1.2 * coeficiente;
        break;
      case 'atividadeModerada':
        totalCalories = tmb * 1.4 * coeficiente;
        break;
      case 'muitoAtivo':
        totalCalories = tmb * 1.6 * coeficiente;
        break;
      default:
        totalCalories = tmb * 1.8 * coeficiente;
        break;
    }

    totalProtein = peso * (nivelAtividade == 'muitoAtivo' ? 2 : 2);
    totalCarbs = (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;

    return MealGoal(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }
}