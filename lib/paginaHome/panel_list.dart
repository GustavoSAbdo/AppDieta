import 'package:flutter/material.dart';
import 'classes.dart'; // Certifique-se de que este import está correto e inclui suas classes Refeicao e FoodItem

class MyExpansionPanelListWidget extends StatefulWidget {
  final String userId;
  final List<Refeicao> refeicoes;
  final Function(int, Refeicao) onRefeicaoUpdated;

  const MyExpansionPanelListWidget({
    Key? key,
    required this.userId,
    required this.refeicoes,
    required this.onRefeicaoUpdated,
  }) : super(key: key);

  @override
  _MyExpansionPanelListWidgetState createState() => _MyExpansionPanelListWidgetState();
}

class _MyExpansionPanelListWidgetState extends State<MyExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: widget.refeicoes.asMap().entries.map((entry) {
          int index = entry.key;
          Refeicao refeicao = entry.value;

          return ExpansionPanelRadio(
            value: index,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text('Refeição ${index + 1}'),
              );
            },
            body: Column(
              children: refeicao.items.map((foodItem) => ListTile(
                title: Text(foodItem.name),
                subtitle: Text('Calorias: ${foodItem.calories}, Proteínas: ${foodItem.protein}, Carboidratos: ${foodItem.carbs}, Gorduras: ${foodItem.fats}'),
              )).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
