import 'package:complete/main.dart';
import 'package:complete/homePage/button/own_food_dialog.dart';
import 'package:flutter/material.dart';
import 'package:complete/homePage/button/search_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/homePage/classes.dart';
import 'dart:math';
import 'package:complete/homePage/hive/hive_food_item.dart';
import 'package:complete/homePage/button/search_food_hive.dart';

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
  FoodDialogs? foodDialogs;
  List<int> modifiedMeals = [];

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
                              onChanged: modifiedMeals.contains(i)
                                  ? null
                                  : (int? value) {
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
                  child: const Text('Próximo'),
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
    bool shouldContinue = true; // Variável de controle
    bool searchInOwnFoods =
        false; // Variável para alternar entre os widgets de seleção de alimentos

    // Função para mostrar o diálogo de seleção de alimentos por macronutriente
    Future<void> selectFoodByNutrient(
        String nutrient, List<FoodItem> targetList) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(
                    'Selecione um alimento em que a maioria das calorias é $nutrient'),
                content: SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: searchInOwnFoods
                      ? SearchAndSelectFoodFromHiveWidget(
                          nutrientDominant:
                              nutrient, // Filtro de macronutriente
                          foodBox: foodBox, // Passa foodBox como um argumento
                          onFoodSelected: (HiveFoodItem selectedFood) {
                            // Adiciona o alimento selecionado à lista correspondente
                            targetList
                                .add(FoodItem.fromMap(selectedFood.toMap()));
                            searchInOwnFoods =
                                false; // Define searchInOwnFoods como false
                            Navigator.of(context)
                                .pop(); // Fecha o diálogo após a seleção
                          },
                        )
                      : SearchAndSelectFoodWidget(
                          nutrientDominant:
                              nutrient, // Filtro de macronutriente
                          onFoodSelected: (Map<String, dynamic> selectedFood) {
                            // Converte o mapa do alimento selecionado para o objeto FoodItem e adiciona à lista correspondente
                            FoodItem foodItem = FoodItem.fromMap(selectedFood);
                            targetList.add(foodItem);
                            searchInOwnFoods =
                                false; // Define searchInOwnFoods como false
                            Navigator.of(context)
                                .pop(); // Fecha o diálogo após a seleção
                          },
                        ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchInOwnFoods = !searchInOwnFoods;
                      });
                    },
                    child: const Text('Procurar em alimentos próprios'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          shouldContinue =
                              false; // Atualiza a variável de controle
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchInOwnFoods = false;
                          });
                        },
                        child: const Text('Procurar alimentos'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Chama sequencialmente para cada categoria de macronutriente
    await selectFoodByNutrient('carboidrato', tempSelectedFoodsCarb);
    if (!shouldContinue) return; // Verifica se deve continuar
    await selectFoodByNutrient('proteina', tempSelectedFoodsProtein);
    if (!shouldContinue) return; // Verifica se deve continuar
    await selectFoodByNutrient('gordura', tempSelectedFoodsFat);
    mealGoal = widget.mealGoal;
    List<FoodItemWithQuantity> allSelectedFoodsWithQuantities =
        calculateFoodQuantities(tempSelectedFoodsCarb, tempSelectedFoodsProtein,
            tempSelectedFoodsFat, widget.mealGoal);

    // Apresenta a visão geral das quantidades de alimentos selecionados para confirmação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confira os alimentos e quantidades selecionados'),
          content: SingleChildScrollView(
            child: ListBody(
              children: allSelectedFoodsWithQuantities
                  .map((item) => ListTile(
                        title: Text(item.foodItem.name),
                        trailing: Text('${item.quantity.toStringAsFixed(2)}g'),
                      ))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                for (var foodItemWithQuantity
                    in allSelectedFoodsWithQuantities) {
                  // Extrai FoodItem e a quantidade de FoodItemWithQuantity
                  FoodItem foodItem = foodItemWithQuantity.foodItem;
                  double quantity = foodItemWithQuantity.quantity;

                  // Chama widget.onFoodAdded com o FoodItem extraído e a quantidade
                  widget.onFoodAdded(selectedRefeicaoIndex, foodItem, quantity);
                }
                // Adicione a refeição selecionada à lista de refeições modificadas
                setState(() {
                  modifiedMeals.add(selectedRefeicaoIndex);
                });
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
    double currentProt = 0, currentCarb = 0, currentGord = 0;
    double holderGord;

    List<FoodItemWithQuantity> result = [];
    double porcMaisProt = goal.totalProtein * 1.05;
    double porcMaisCarb = goal.totalCarbs * 1.05;
    double porcMaisGord = goal.totalFats * 1.05;
    double porcMenosProt = goal.totalProtein * 0.95;
    double porcMenosCarb = goal.totalCarbs * 0.95;
    double porcMenosGord = goal.totalFats * 0.95;

    FoodItem alimentoProt = protein[0];
    double protAlimentoProt = alimentoProt.protein / 100;
    double carbAlimentoProt = alimentoProt.carbs / 100;
    double gordAlimentoProt = alimentoProt.fats / 100;
    double totalProtAlimentoProt = 0;
    double totalCarbAlimentoProt = 0;
    double totalGordAlimentoProt = 0;
    double qntAlimentoProt = 0;

    FoodItem alimentoCarb = carbs[0];
    double protAlimentoCarb = alimentoCarb.protein / 100;
    double carbAlimentoCarb = alimentoCarb.carbs / 100;
    double gordAlimentoCarb = alimentoCarb.fats / 100;
    double totalProtAlimentoCarb = 0;
    double totalCarbAlimentoCarb = 0;
    double totalGordAlimentoCarb = 0;
    double qntAlimentoCarb = 0;

    FoodItem alimentoGord = fats[0];
    double protAlimentoGord = alimentoGord.protein / 100;
    double carbAlimentoGord = alimentoGord.carbs / 100;
    double gordAlimentoGord = alimentoGord.fats / 100;
    double totalProtAlimentoGord = 0;
    double totalCarbAlimentoGord = 0;
    double totalGordAlimentoGord = 0;
    double qntAlimentoGord = 0;

    void calculaAlimentoProt() {
      totalProtAlimentoProt = protAlimentoProt * qntAlimentoProt;
      totalCarbAlimentoProt = carbAlimentoProt * qntAlimentoProt;
      totalGordAlimentoProt = gordAlimentoProt * qntAlimentoProt;
    }

    // holderGord = goal.totalFats * 0.6;
    // qntAlimentoGord = holderGord / gordAlimentoGord;

    void calculaAlimentoGord() {
      totalProtAlimentoGord = protAlimentoGord * qntAlimentoGord;
      totalCarbAlimentoGord = carbAlimentoGord * qntAlimentoGord;
      totalGordAlimentoGord = gordAlimentoGord * qntAlimentoGord;
    }
    //calculaAlimentoGord();

    // holderCarb = goal.totalCarbs * 0.8;
    // qntAlimentoCarb = holderCarb / carbAlimentoCarb;

    void calculaAlimentoCarb() {
      totalProtAlimentoCarb = protAlimentoCarb * qntAlimentoCarb;
      totalCarbAlimentoCarb = carbAlimentoCarb * qntAlimentoCarb;
      totalGordAlimentoCarb = gordAlimentoCarb * qntAlimentoCarb;
    }

    //calculaAlimentoCarb();

    void calculaProt() {
      currentProt =
          totalProtAlimentoProt + totalProtAlimentoCarb + totalProtAlimentoGord;
    }

    void calculaCarb() {
      currentCarb =
          totalCarbAlimentoGord + totalCarbAlimentoCarb + totalCarbAlimentoProt;
    }

    void calculaGord() {
      currentGord =
          totalGordAlimentoGord + totalGordAlimentoCarb + totalGordAlimentoProt;
    }

    void calculaTudo() {
      calculaCarb();
      calculaProt();
      calculaGord();
    }

    // holderProt = goal.totalProtein * 0.7;
    // qntAlimentoProt = holderProt / protAlimentoProt;
    // calculaAlimentoProt();
    // calculaTudo();

    holderGord = goal.totalFats * 0.7;
    qntAlimentoGord = holderGord / gordAlimentoGord;
    calculaAlimentoGord();
    calculaTudo();

    qntAlimentoProt =
        ((goal.totalProtein - currentProt) / protAlimentoProt) * 0.9;
    calculaAlimentoProt();
    calculaTudo();

    qntAlimentoCarb = (goal.totalCarbs - currentCarb) / carbAlimentoCarb;
    calculaAlimentoCarb();
    calculaTudo();

    for (int i = 0; i < 4; i++) { 

      // Gordura
      if (currentGord > porcMaisGord || currentGord < porcMenosGord) {
        if (currentGord < porcMenosGord) {
          qntAlimentoGord = qntAlimentoGord +
              ((goal.totalFats - currentGord) / gordAlimentoGord);
        } else {
          qntAlimentoGord = qntAlimentoGord -
              ((currentGord - goal.totalFats) / gordAlimentoGord);
        }
        qntAlimentoGord =
            max(qntAlimentoGord, 0); 
        calculaAlimentoGord();
        calculaTudo();
      }

      // Carboidrato
      if (currentCarb > porcMaisCarb || currentCarb < porcMenosCarb) {
        if (currentCarb < porcMenosCarb) {
          qntAlimentoCarb = qntAlimentoCarb +
              ((goal.totalCarbs - currentCarb) / carbAlimentoCarb);
        } else {
          qntAlimentoCarb = qntAlimentoCarb -
              ((currentCarb - goal.totalCarbs) / carbAlimentoCarb);
        }
        qntAlimentoCarb =
            max(qntAlimentoCarb, 0); 
        calculaAlimentoCarb();
        calculaTudo();
      }
         
      // Proteína
      if (currentProt > porcMaisProt || currentProt < porcMenosProt) {
        if (currentProt < porcMenosProt) {
          qntAlimentoProt = qntAlimentoProt +
              ((goal.totalProtein - currentProt) / protAlimentoProt);
        } else {
          qntAlimentoProt = qntAlimentoProt -
              ((currentProt - goal.totalProtein) / protAlimentoProt);
        }
        qntAlimentoProt =
            max(qntAlimentoProt, 0); 
        calculaAlimentoProt();
        calculaTudo();
      }

    }

    result.add(FoodItemWithQuantity(
        foodItem: alimentoProt, quantity: qntAlimentoProt));
    result.add(FoodItemWithQuantity(
        foodItem: alimentoCarb, quantity: qntAlimentoCarb));
    result.add(FoodItemWithQuantity(
        foodItem: alimentoGord, quantity: qntAlimentoGord));

    return result;
  }

  @override
  void initState() {
    super.initState();
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
  }

  @override
  Widget build(BuildContext context) {
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
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
                  foodDialogs!.showDeleteFoodDialog(context);
                } else if (value == 'addOwn') {
                  foodDialogs!.showAddOwnFoodDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add',
                  child: Text('Adicionar Refeição'),
                ),
                const PopupMenuItem<String>(
                  value: 'addOwn',
                  child: Text('Adicionar Alimento Próprio'),
                ),
                const PopupMenuItem<String>(
                  value: 'remove',
                  child: Text('Remover Alimento Próprio'),
                ),
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
