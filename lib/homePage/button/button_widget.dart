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
  bool verificationProt = false;
  bool verificationCarb = false;
  bool verificationGord = false;
  List<FoodItemWithQuantity> allSelectedFoodsWithQuantities = [];
  Offset position = Offset(0, 0);

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
                            FoodItem foodItem = FoodItem.fromMap(selectedFood);
                            targetList.add(foodItem);
                            searchInOwnFoods = false;
                          },
                        ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchInOwnFoods = !searchInOwnFoods;
                          });
                        },
                        child: const Text('Alimentos próprios'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchInOwnFoods = false;
                          });
                        },
                        child: const Text('Banco de dados'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          shouldContinue = false;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Próximo'),
                      ),
                    ],
                  )
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
    bool controllerProteinMais = verificaAliMais(tempSelectedFoodsProtein);
    bool controllerCarbsMais = verificaAliMais(tempSelectedFoodsCarb);
    bool controllerFatsMais = verificaAliMais(tempSelectedFoodsFat);

    if (controllerFatsMais || controllerCarbsMais || controllerProteinMais) {
      allSelectedFoodsWithQuantities = calculateFoodQuantitiesUmAMais(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          widget.mealGoal);
    } else {
      allSelectedFoodsWithQuantities = calculateFoodQuantities(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          widget.mealGoal);
    }

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

  List<FoodItemWithQuantity> calculateQuantities(
      FoodItem carbs, FoodItem protein, FoodItem fats, MealGoal goal) {
    double currentProt = 0, currentCarb = 0, currentGord = 0;

    List<FoodItemWithQuantity> result = [];
    double porcMaisProt = goal.totalProtein * 1.05;
    double porcMaisCarb = goal.totalCarbs * 1.05;
    double porcMaisGord = goal.totalFats * 1.05;
    double porcMenosProt = goal.totalProtein * 0.95;
    double porcMenosCarb = goal.totalCarbs * 0.95;
    double porcMenosGord = goal.totalFats * 0.95;

    protein.name;
    double protAlimentoProt = protein.protein / 100;
    double carbAlimentoProt = protein.carbs / 100;
    double gordAlimentoProt = protein.fats / 100;
    double totalProtAlimentoProt = 0;
    double totalCarbAlimentoProt = 0;
    double totalGordAlimentoProt = 0;
    double qntAlimentoProt = 0;

    double protAlimentoCarb = carbs.protein / 100;
    double carbAlimentoCarb = carbs.carbs / 100;
    double gordAlimentoCarb = carbs.fats / 100;
    double totalProtAlimentoCarb = 0;
    double totalCarbAlimentoCarb = 0;
    double totalGordAlimentoCarb = 0;
    double qntAlimentoCarb = 0;

    double protAlimentoGord = fats.protein / 100;
    double carbAlimentoGord = fats.carbs / 100;
    double gordAlimentoGord = fats.fats / 100;
    double totalProtAlimentoGord = 0;
    double totalCarbAlimentoGord = 0;
    double totalGordAlimentoGord = 0;
    double qntAlimentoGord = 0;

    void calculaAlimentoProt() {
      totalProtAlimentoProt = protAlimentoProt * qntAlimentoProt;
      totalCarbAlimentoProt = carbAlimentoProt * qntAlimentoProt;
      totalGordAlimentoProt = gordAlimentoProt * qntAlimentoProt;
    }

    void calculaAlimentoGord() {
      totalProtAlimentoGord = protAlimentoGord * qntAlimentoGord;
      totalCarbAlimentoGord = carbAlimentoGord * qntAlimentoGord;
      totalGordAlimentoGord = gordAlimentoGord * qntAlimentoGord;
    }

    void calculaAlimentoCarb() {
      totalProtAlimentoCarb = protAlimentoCarb * qntAlimentoCarb;
      totalCarbAlimentoCarb = carbAlimentoCarb * qntAlimentoCarb;
      totalGordAlimentoCarb = gordAlimentoCarb * qntAlimentoCarb;
    }

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

    // double holderGord = goal.totalFats * 0.7;
    // qntAlimentoGord = holderGord / gordAlimentoGord;
    // calculaAlimentoGord();
    // calculaTudo();

    double holderProt = goal.totalProtein * 0.7;
    qntAlimentoProt = holderProt / protAlimentoProt;
    calculaAlimentoProt();
    calculaTudo();

    qntAlimentoGord = (goal.totalFats - currentGord) / gordAlimentoGord * 0.8;
    calculaAlimentoGord();
    calculaTudo();

    // qntAlimentoProt =
    //     ((goal.totalProtein - currentProt) / protAlimentoProt) * 0.9;
    // calculaAlimentoProt();
    // calculaTudo();

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
        qntAlimentoGord = max(qntAlimentoGord, 0);
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
        qntAlimentoCarb = max(qntAlimentoCarb, 0);
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
        qntAlimentoProt = max(qntAlimentoProt, 0);
        calculaAlimentoProt();
        calculaTudo();
      }
    }

    result.add(
        FoodItemWithQuantity(foodItem: protein, quantity: qntAlimentoProt));
    result
        .add(FoodItemWithQuantity(foodItem: carbs, quantity: qntAlimentoCarb));
    result.add(FoodItemWithQuantity(foodItem: fats, quantity: qntAlimentoGord));

    return result;
  }

  bool verificaAliMais(List macro) {
    return macro.length >= 2;
  }

  bool verificaAliMenos(List macro) {
    return macro.isEmpty;
  }

  List<FoodItem> funcListaVazia(List<FoodItem> lista) {
    List<FoodItem> result = [];

    if (verificaAliMenos(lista)) {
      FoodItem foodItemVazio = FoodItem(
        name: '',
        calories: 1,
        protein: 1,
        carbs: 1,
        fats: 1,
        quantity: 1,
        dominantNutrient: '',
      );

      result.add(foodItemVazio);
    } else {
      result = lista;
    }
    return result;
  }



  @override
  void initState() {
    super.initState();
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      setState(() {
        position = Offset(screenSize.width - 56, screenSize.height - 56);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var numRef = userData['numRefeicoes'] ?? 0;

          return Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      var newX = position.dx + details.delta.dx;
                      var newY = position.dy + details.delta.dy;

                      const leftPadding = 30.0;
                      const topPadding = 55.0;

                      newX = newX.clamp(leftPadding, screenSize.width - 56);
                      newY = newY.clamp(
                          statusBarHeight + appBarHeight + topPadding,
                          screenSize.height - 56);

                      position = Offset(newX, newY);
                    });
                  },
                  child: FloatingActionButton(
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
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
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
                  ),
                ),
              ),
            ],
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
