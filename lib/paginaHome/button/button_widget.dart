import 'package:flutter/material.dart';
import 'package:complete/paginaHome/button/search_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/paginaHome/classes.dart';
import 'package:complete/paginaHome/home.dart';


class AddRemoveFoodWidget extends StatefulWidget {
  final String userId;
  final Function(int, FoodItem) onFoodAdded;

  const AddRemoveFoodWidget({Key? key, required this.userId, required this.onFoodAdded}) : super(key: key);
  @override
  _AddRemoveFoodWidgetState createState() => _AddRemoveFoodWidgetState();
}

class _AddRemoveFoodWidgetState extends State<AddRemoveFoodWidget> {
  int selectedRefeicaoIndex = 0;

  void showRefeicaoDialog(int numRef) {
  // Define a variável selectedRefeicao fora do builder do showDialog
  int? selectedRefeicao;

  showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( // Usa StatefulBuilder para gerenciar o estado local do diálogo
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Escolha uma Refeição'),
            content: SingleChildScrollView(
              child: ListBody(
                children: List<Widget>.generate(numRef, (i) => ListTile(
                      title: Text('Refeição ${i + 1}'),
                      leading: Radio<int>(
                        value: i,
                        groupValue: selectedRefeicao,
                        onChanged: (int? value) {
                          // Atualiza o estado do diálogo, não do widget inteiro
                          setStateDialog(() {
                            selectedRefeicao = value;
                          });
                        },
                      ),
                    )),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Passa o valor de selectedRefeicao diretamente
                  if (selectedRefeicao != null) {
                    Navigator.of(context).pop(selectedRefeicao);
                  }
                },
                child: Text('Próximo'),
              ),
            ],
          );
        },
      );
    },
  ).then((selectedRefeicaoResult) {
    // "selectedRefeicaoResult" contém o valor da opção escolhida
    if (selectedRefeicaoResult != null) {
      setState(() {
        selectedRefeicaoIndex = selectedRefeicaoResult; // Aqui você atualiza o estado com o índice selecionado
      });
      // Depois de atualizar o índice, chame _showAddFoodDialog
      _showAddFoodDialog(selectedRefeicaoResult); // Passa o índice da refeição selecionada
    }
  });
}



  void _showAddFoodDialog(int selectedRefeicaoIndex) {
  // Lista temporária para armazenar alimentos selecionados
  List<FoodItem> tempSelectedFoods = [];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Adicionar Alimentos'),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: SearchAndSelectFoodWidget(
            onFoodSelected: (Map<String, dynamic> selectedFood) {
              // Aqui, apenas adicionamos o alimento selecionado à lista temporária
              FoodItem foodItem = FoodItem.fromMap(selectedFood);
              tempSelectedFoods.add(foodItem);
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          // Botão para confirmar a adição dos alimentos selecionados
          TextButton(
            onPressed: () {
              // Aqui, iteramos sobre os alimentos selecionados e os adicionamos à refeição
              // Isso assume que você tem uma maneira de adicionar vários alimentos de uma vez ou
              // que irá adicionar cada alimento individualmente dentro de onFoodAdded.
              for (var foodItem in tempSelectedFoods) {
                widget.onFoodAdded(selectedRefeicaoIndex, foodItem);
              }
              // Fecha o diálogo após confirmar a adição
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var numRef = userData['numRefeicoes'] ?? 0;

          return FloatingActionButton(
            onPressed: () {},
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'add') {
                  showRefeicaoDialog(numRef);
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
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Quando os dados estão sendo carregados...
          return const Center(child: CircularProgressIndicator());
        } else {
          // Para outros estados, como erro ou dados não encontrados
          return const Center(
              child: Text("Não foi possível carregar os dados."));
        }
      },
    );
  }
}
