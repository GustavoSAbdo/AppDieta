import 'package:flutter/material.dart';
import 'package:complete/paginaHome/user_food_item.dart';

class FoodDialogs {
  final BuildContext context;
  final foodBox; 

  FoodDialogs({required this.context, required this.foodBox});

  void showAddOwnFoodDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final gramsController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar alimento próprio'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: gramsController,
                    decoration: const InputDecoration(labelText: 'Gramas'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira as gramas';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: proteinController,
                    decoration: const InputDecoration(labelText: 'Proteína'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a proteína';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: carbsController,
                    decoration:
                        const InputDecoration(labelText: 'Carboidratos'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira os carboidratos';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: fatsController,
                    decoration: const InputDecoration(labelText: 'Gorduras'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira as gorduras';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Calcula as calorias
                  double calories = (4 *
                          (double.parse(carbsController.text) +
                              double.parse(proteinController.text))) +
                      (9 * double.parse(fatsController.text));

                  // Calcula os valores por 100g
                  double grams = double.parse(gramsController.text);
                  double caloriesPer100g = (calories / grams) * 100;
                  double proteinPer100g =
                      (double.parse(proteinController.text) / grams) * 100;
                  double carbsPer100g =
                      (double.parse(carbsController.text) / grams) * 100;
                  double fatsPer100g =
                      (double.parse(fatsController.text) / grams) * 100;
                  String dominantNutrient;
                  double proteinCalories = proteinPer100g * 4;
                  double carbsCalories = carbsPer100g * 4;
                  double fatsCalories = fatsPer100g * 9;

                  if (proteinCalories > carbsCalories &&
                      proteinCalories > fatsCalories) {
                    dominantNutrient = 'proteina';
                  } else if (carbsCalories > proteinCalories &&
                      carbsCalories > fatsCalories) {
                    dominantNutrient = 'carboidrato';
                  } else {
                    dominantNutrient = 'gordura';
                  }

                  foodBox.add(FoodItem(
                    name: nameController.text,
                    calories: caloriesPer100g,
                    protein: proteinPer100g,
                    carbs: carbsPer100g,
                    fats: fatsPer100g,
                    dominantNutrient: dominantNutrient,
                    quantity: 100,
                  ));

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteFoodDialog(BuildContext context) async {
    List<FoodItem> foodsToDelete = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Excluir alimentos'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
                      title: const Text('Carboidratos',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'carboidrato')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food as FoodItem);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Proteinas',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'proteina')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food as FoodItem);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text('Gorduras',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'gordura')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },                              
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Concluir exclusão'),
                  onPressed: () {
                    for (var food in foodsToDelete) {
                      var key = foodBox.keys.firstWhere(
                          (k) => foodBox.get(k) == food,
                          orElse: () => null);
                      if (key != null) {
                        foodBox.delete(key);
                      }
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
