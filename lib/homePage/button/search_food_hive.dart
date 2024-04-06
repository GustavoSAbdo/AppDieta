import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/homePage/hive/hive_food_item.dart';


class SearchAndSelectFoodFromHiveWidget extends StatefulWidget {
  final Function(HiveFoodItem) onFoodSelected;
  final String nutrientDominant;
  final Box<HiveFoodItem> foodBox;

  SearchAndSelectFoodFromHiveWidget(
      {Key? key, required this.onFoodSelected, required this.nutrientDominant, required this.foodBox})
      : super(key: key);

  @override
  _SearchAndSelectFoodFromHiveWidgetState createState() =>
      _SearchAndSelectFoodFromHiveWidgetState();
}

class _SearchAndSelectFoodFromHiveWidgetState
    extends State<SearchAndSelectFoodFromHiveWidget> {
  String searchQuery = '';
  List<HiveFoodItem> selectedFoods = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addFoodToSelected(HiveFoodItem foodItem) {
    setState(() {
      selectedFoods.add(foodItem);
      widget.onFoodSelected(foodItem);
    });
    searchController.clear();
    searchQuery = '';
    FocusScope.of(context).unfocus();
  }

  void removeFoodAt(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Pesquisar Alimento Próprio',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: searchQuery.isEmpty
              ? ListView.builder(
                  itemCount: selectedFoods.length,
                  itemBuilder: (context, index) {
                    final food = selectedFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text('Calorias: ${food.calories.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => removeFoodAt(index),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: widget.foodBox.length,
                  itemBuilder: (context, index) {
                    HiveFoodItem? foodItem = widget.foodBox.getAt(index);
                    if (foodItem != null &&
                        foodItem.name.toLowerCase().contains(searchQuery) &&
                        foodItem.dominantNutrient == widget.nutrientDominant) {
                      return ListTile(
                        title: Text(foodItem.name),
                        subtitle: Text('Calorias: ${foodItem.calories.toStringAsFixed(2)}, Carboidrato: ${foodItem.carbs.toStringAsFixed(2)}, Proteina: ${foodItem.protein.toStringAsFixed(2)}, Gordura: ${foodItem.fats.toStringAsFixed(2)}, '),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => addFoodToSelected(foodItem),
                        ),
                      );
                    } else {
                      return Container(); // Retorna um container vazio para alimentos que não correspondem à consulta de pesquisa
                    }
                  },
                ),
        ),
      ],
    );
  }
}