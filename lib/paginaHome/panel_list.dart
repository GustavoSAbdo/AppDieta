import 'package:flutter/material.dart';
import 'classes.dart'; // Certifique-se de que este import está correto e inclui suas classes Refeicao e FoodItem

class MyExpansionPanelListWidget extends StatefulWidget {
  final String userId;
  final List<Refeicao> refeicoes;
  final Function(int, Refeicao) onRefeicaoUpdated;
  // Adicionando totalDiario de nutrientes como parâmetros por simplicidade
  final double totalDailyCalories;
  final double totalDailyProtein;
  final double totalDailyCarbs;
  final double totalDailyFats;
  final int numRef;

  const MyExpansionPanelListWidget({
    Key? key,
    required this.userId,
    required this.refeicoes,
    required this.onRefeicaoUpdated,
    required this.totalDailyCalories,
    required this.totalDailyProtein,
    required this.totalDailyCarbs,
    required this.totalDailyFats,
    required this.numRef,
  }) : super(key: key);

  @override
  _MyExpansionPanelListWidgetState createState() => _MyExpansionPanelListWidgetState();
}

class _MyExpansionPanelListWidgetState extends State<MyExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    // Aqui você divide igualmente os nutrientes pelo número de refeições.
    double mealCalories = widget.totalDailyCalories / widget.numRef;
    double mealProtein = widget.totalDailyProtein / widget.numRef;
    double mealCarbs = widget.totalDailyCarbs / widget.numRef;
    double mealFats = widget.totalDailyFats / widget.numRef;

    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: widget.refeicoes.asMap().entries.map((entry) {
          int index = entry.key;
          Refeicao refeicao = entry.value;

          // Adicione aqui mais lógica se precisar calcular os totais de cada item dentro da refeição.

          return ExpansionPanelRadio(
            value: index,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text('Refeição ${index + 1}'),
                // Você pode querer mostrar um resumo dos totais aqui.
              );
            },
            body: Column(
              children: refeicao.items.map((foodItem) => ListTile(
                title: Text(foodItem.name),
                subtitle: Text('Calorias: ${foodItem.calories.toStringAsFixed(2)}, Proteínas: ${foodItem.protein.toStringAsFixed(2)}, Carboidratos: ${foodItem.carbs.toStringAsFixed(2)}, Gorduras: ${foodItem.fats.toStringAsFixed(2)}'),
              )).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
