import 'package:flutter/material.dart';
import 'search_food.dart';

class AddRemoveFoodWidget extends StatefulWidget {
  @override
  _AddRemoveFoodWidgetState createState() => _AddRemoveFoodWidgetState();
}

class _AddRemoveFoodWidgetState extends State<AddRemoveFoodWidget> {
  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Alimento'),
          // Substitui o conteúdo estático pelo SearchFoodWidget
          content: Container(
            // Defina uma altura específica se necessário
            height: 300,
            width: double.maxFinite, // Para usar a largura máxima possível
            child: SearchFoodWidget(
                // Você pode passar aqui os parâmetros necessários para o SearchFoodWidget, se houver
                ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            // O botão de adicionar pode ser manipulado de acordo com a seleção feita no SearchFoodWidget
            TextButton(
              onPressed: () {
                // A lógica para adicionar o alimento selecionado vai aqui
                // Isso dependerá de como o SearchFoodWidget comunica a seleção de alimentos
                Navigator.of(context).pop();
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveFoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Aqui retorna o widget para o popup de remover alimento
        return AlertDialog(
          title: Text('Remover Alimento'),
          content: Text('Implementar formulário de remoção aqui.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para remover alimento
                Navigator.of(context).pop();
              },
              child: Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'add') {
            _showAddFoodDialog();
          } else if (value == 'remove') {
            _showRemoveFoodDialog();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'add',
            child: Text('Adicionar Alimento'),
          ),
          const PopupMenuItem<String>(
            value: 'remove',
            child: Text('Remover Alimento'),
          ),
        ],
        icon: Icon(Icons.add),
      ),
    );
  }
}
