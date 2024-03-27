import 'package:flutter/material.dart';
import 'package:complete/paginaHome/button/search_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/paginaHome/classes.dart';
import 'dart:math';

class AddRemoveFoodWidget extends StatefulWidget {
  final String userId;
  final Function(int, FoodItem, double) onFoodAdded;
  final MealGoal mealGoal;

  const AddRemoveFoodWidget(
      {Key? key,
      required this.userId,
      required this.onFoodAdded,
      required this.mealGoal})
      : super(key: key);
  @override
  _AddRemoveFoodWidgetState createState() => _AddRemoveFoodWidgetState();
}

class _AddRemoveFoodWidgetState extends State<AddRemoveFoodWidget> {
  int selectedRefeicaoIndex = 0;
  late MealGoal mealGoal;

  void showRefeicaoDialog(int numRef) {
    // Define a variável selectedRefeicao fora do builder do showDialog
    int? selectedRefeicao;

    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Usa StatefulBuilder para gerenciar o estado local do diálogo
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Escolha uma Refeição'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: List<Widget>.generate(
                      numRef,
                      (i) => ListTile(
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
                  child: const Text('Cancelar'),
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
          selectedRefeicaoIndex =
              selectedRefeicaoResult; // Aqui você atualiza o estado com o índice selecionado
        });
        // Depois de atualizar o índice, chame _showAddFoodDialog
        _showAddFoodDialog(
            selectedRefeicaoResult); // Passa o índice da refeição selecionada
      }
    });
  }

  void _showAddFoodDialog(int selectedRefeicaoIndex) async {
    List<FoodItem> tempSelectedFoodsCarb = [];
    List<FoodItem> tempSelectedFoodsProtein = [];
    List<FoodItem> tempSelectedFoodsFat = [];
    print('MealGoal: Protein ${widget.mealGoal.totalProtein}, Carbs ${widget.mealGoal.totalCarbs}, Fats ${widget.mealGoal.totalFats}');
    // Função para mostrar o diálogo de seleção de alimentos por macronutriente
    Future<void> selectFoodByNutrient(
        String nutrient, List<FoodItem> targetList) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione uma fonte de $nutrient'),
            content: SizedBox(
              height: 300,
              width: double.maxFinite,
              child: SearchAndSelectFoodWidget(
                nutrientDominant: nutrient, // Filtro de macronutriente
                onFoodSelected: (Map<String, dynamic> selectedFood) {
                  // Converte o mapa do alimento selecionado para o objeto FoodItem e adiciona à lista correspondente
                  FoodItem foodItem = FoodItem.fromMap(selectedFood);
                  targetList.add(foodItem);
                  Navigator.of(context).pop(); // Fecha o diálogo após a seleção
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }

    // Chama sequencialmente para cada categoria de macronutriente
    await selectFoodByNutrient('carboidrato', tempSelectedFoodsCarb);
    await selectFoodByNutrient('proteina', tempSelectedFoodsProtein);
    await selectFoodByNutrient('gordura', tempSelectedFoodsFat);
    mealGoal = widget.mealGoal;
    List<FoodItemWithQuantity> allSelectedFoodsWithQuantities = calculateFoodQuantities(
        tempSelectedFoodsCarb,
        tempSelectedFoodsProtein,
        tempSelectedFoodsFat,
        widget.mealGoal);

    // Apresenta a visão geral das quantidades de alimentos selecionados para confirmação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirme os alimentos e quantidades selecionados'),
          content: SingleChildScrollView(
            child: ListBody(
              children: allSelectedFoodsWithQuantities.map((item) => ListTile(
                title: Text(item.foodItem.name),
                trailing: Text('${item.quantity.toStringAsFixed(2)}g'),
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                for (var foodItemWithQuantity in allSelectedFoodsWithQuantities) {
                // Extrai FoodItem e a quantidade de FoodItemWithQuantity
                FoodItem foodItem = foodItemWithQuantity.foodItem;
                double quantity = foodItemWithQuantity.quantity;

                // Chama widget.onFoodAdded com o FoodItem extraído e a quantidade
                widget.onFoodAdded(selectedRefeicaoIndex, foodItem, quantity);
              }
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
}

  List<FoodItemWithQuantity> calculateFoodQuantities(List<FoodItem> carbs,
    List<FoodItem> protein, List<FoodItem> fats, MealGoal goal) {
    print(goal);
    double currentProt, currentCarb, currentGord;
    double holderProt, holderCarb, holderGord;
    List<FoodItemWithQuantity> result = [];
    //foodQuantities[food.name] = quantity;
    FoodItem alimentoProt = protein[0];
    double protAlimentoProt = alimentoProt.protein/100;
    double carbAlimentoProt = alimentoProt.carbs/100;
    double gordAlimentoProt = alimentoProt.fats/100;
    double qntAlimentoProt;
    

    FoodItem alimentoCarb = carbs[0];
    double protAlimentoCarb = alimentoCarb.protein/100;
    double carbAlimentoCarb = alimentoCarb.carbs/100;
    double gordAlimentoCarb = alimentoCarb.fats/100;
    double qntAlimentoCarb;

    FoodItem alimentoGord = fats[0];
    double protAlimentoGord = alimentoGord.protein/100;
    double carbAlimentoGord = alimentoGord.carbs/100;
    double gordAlimentoGord = alimentoGord.fats/100;
    double qntAlimentoGord;
    holderProt = goal.totalProtein * 0.7;
    
    qntAlimentoProt = holderProt / protAlimentoProt;
    holderProt = 0;
    protAlimentoProt = protAlimentoProt * qntAlimentoProt;
    carbAlimentoProt = carbAlimentoProt * qntAlimentoProt;
    gordAlimentoProt = gordAlimentoProt * qntAlimentoProt;    
    
    holderGord = goal.totalFats * 0.5;
    qntAlimentoGord = holderGord / gordAlimentoGord;
    holderGord = 0;
    protAlimentoGord = protAlimentoGord * qntAlimentoGord;
    carbAlimentoGord = carbAlimentoGord * qntAlimentoGord;
    gordAlimentoGord = gordAlimentoGord * qntAlimentoGord; 


    holderCarb = goal.totalCarbs * 0.8;
    qntAlimentoCarb = holderCarb / carbAlimentoCarb;
    holderCarb = 0;
    protAlimentoCarb = protAlimentoCarb * qntAlimentoCarb;
    carbAlimentoCarb = carbAlimentoCarb * qntAlimentoCarb;
    gordAlimentoCarb = gordAlimentoCarb * qntAlimentoCarb;

    currentProt = protAlimentoGord + protAlimentoCarb + protAlimentoProt;
    currentCarb = carbAlimentoGord + carbAlimentoCarb + carbAlimentoProt;
    currentGord = gordAlimentoGord + gordAlimentoCarb + gordAlimentoProt;
    
    result.add(FoodItemWithQuantity(foodItem: alimentoProt, quantity: qntAlimentoProt));
    result.add(FoodItemWithQuantity(foodItem: alimentoCarb, quantity: qntAlimentoCarb));
    result.add(FoodItemWithQuantity(foodItem: alimentoGord, quantity: qntAlimentoGord));
    
    return result;
  }

  void _showRemoveFoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Aqui retorna o widget para o popup de remover alimento
        return AlertDialog(
          title: const Text('Remover Alimento'),
          content: const Text('Implementar formulário de remoção aqui.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para remover alimento
                Navigator.of(context).pop();
              },
              child: const Text('Remover'),
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
                  child: Text('Adicionar Refeição'),
                ),
                // const PopupMenuItem<String>(
                //   value: 'remove',
                //   child: Text('Remover Alimento'),
                // ),
              ],
              icon: const Icon(Icons.add),
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
