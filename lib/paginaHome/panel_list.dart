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
  final MealGoal mealGoal;

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
    required this.mealGoal
  }) : super(key: key);

  @override
  _MyExpansionPanelListWidgetState createState() =>
      _MyExpansionPanelListWidgetState();
}

class _MyExpansionPanelListWidgetState
    extends State<MyExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    MealGoal mealGoal = widget.mealGoal;

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
              children: [
                // Listagem dos itens alimentares com seus detalhes
                ...refeicao.items
                    .map((foodItem) => ListTile(
                          title: Text('${foodItem.quantity.toStringAsFixed(1)}g de ${foodItem.name}'),
                          subtitle: Text(
                              'Calorias: ${foodItem.calories.toStringAsFixed(2)}, Proteínas: ${foodItem.protein.toStringAsFixed(2)}, Carboidratos: ${foodItem.carbs.toStringAsFixed(2)}, Gorduras: ${foodItem.fats.toStringAsFixed(2)}'),
                        ))
                    .toList(),

                // Um divisor para separar visualmente os itens da refeição do resumo nutricional
                Divider(color: Colors.grey),

                // Bloco Padding para o resumo nutricional
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Alinha o texto à esquerda
                    children: [
                      Text(
                        '🔥 Calorias da refeição: ${refeicao.items.fold(0.0, (double prev, item) => prev + item.calories).toStringAsFixed(2)} / ${mealGoal.totalCalories.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '🍗 Proteínas da refeição: ${refeicao.items.fold(0.0, (double prev, item) => prev + item.protein).toStringAsFixed(2)} / ${mealGoal.totalProtein.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '🍞 Carboidratos da refeição: ${refeicao.items.fold(0.0, (double prev, item) => prev + item.carbs).toStringAsFixed(2)} / ${mealGoal.totalCarbs.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '🥑 Gorduras da refeição: ${refeicao.items.fold(0.0, (double prev, item) => prev + item.fats).toStringAsFixed(2)} / ${mealGoal.totalFats.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
