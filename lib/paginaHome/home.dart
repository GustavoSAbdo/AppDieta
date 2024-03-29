import 'package:complete/paginaHome/classes.dart';
import 'package:complete/paginaHome/nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calorie_tracker.dart';
import 'panel_list.dart';
import 'button/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  final String userId;

  HomePage({Key? key, required this.userId}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  List<Refeicao> refeicoes = [];
  int? selectedRefeicaoIndex;
  int numRef = 0;
  late MealGoal singleMealGoal;

  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;
  double currentCalories = 0;
  double currentProtein = 0;
  double currentCarbs = 0;
  double currentFats = 0;

  final NutritionService nutritionService = NutritionService();

  MealGoal calculateMealGoalForSingleMeal(double totalCalories,
      double totalProtein, double totalCarbs, double totalFats, int numRef) {
    // Assegura que você tenha o total diário e o número de refeições
    final double mealCalories = totalCalories / numRef;
    final double mealProtein = totalProtein / numRef;
    final double mealCarbs = totalCarbs / numRef;
    final double mealFats = totalFats / numRef;

    return MealGoal(
      totalCalories: mealCalories,
      totalProtein: mealProtein,
      totalCarbs: mealCarbs,
      totalFats: mealFats,
    );
  }

  void addFoodToRefeicao(
      int refeicaoIndex, FoodItem foodItem, double quantity) async {
    setState(() {
      foodItem.quantity = quantity; // Define a quantidade do alimento
      foodItem
          .adjustForQuantity(); // Ajusta os valores nutricionais baseados na quantidade

      var newItems = List<FoodItem>.from(refeicoes[refeicaoIndex].items);
      newItems.add(foodItem);
      refeicoes[refeicaoIndex] = Refeicao(items: newItems);

      updateNutrition(
        foodItem.calories,
        foodItem.protein,
        foodItem.carbs,
        foodItem.fats,
      );
    });

  }

  void onRefeicaoUpdated(int index, Refeicao refeicao) {
    setState(() {
      refeicoes[index] = refeicao;
    });
  }

  void updateNutrition(
      double calories, double protein, double carbs, double fats) {
    setState(() {
      currentCalories += calories;
      currentProtein += protein;
      currentCarbs += carbs;
      currentFats += fats;
    });
  }

  void removeNutrition(
      double calories, double protein, double carbs, double fats) {
    setState(() {
      currentCalories = (currentCalories - calories).clamp(0, totalCalories);
      currentProtein = (currentProtein - protein).clamp(0, totalProtein);
      currentCarbs = (currentCarbs - carbs).clamp(0, totalCarbs);
      currentFats = (currentFats - fats).clamp(0, totalFats);
    });
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot userDataSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDataSnapshot.exists) {
        setState(() {
          userData = userDataSnapshot.data() as Map<String, dynamic>?;
          int numRef = int.tryParse(userData!['numRefeicoes'].toString()) ?? 0;
          refeicoes = List<Refeicao>.generate(numRef, (_) => Refeicao());
          MealGoal goal = nutritionService.calculateNutritionalGoals(userData!);
          totalCalories = goal.totalCalories;
          totalProtein = goal.totalProtein;
          totalCarbs = goal.totalCarbs;
          totalFats = goal.totalFats;
          singleMealGoal = calculateMealGoalForSingleMeal(
              totalCalories, totalProtein, totalCarbs, totalFats, numRef);
        });
        checkAndResetRefeicoes();
      }
    }
  }

  Future<void> checkAndResetRefeicoes() async {
    final prefs = await SharedPreferences.getInstance();
    String lastResetDate = prefs.getString('lastResetDate') ?? '';
    String today = DateTime.now()
        .toIso8601String()
        .substring(0, 10); // Apenas a data, sem hora

    if (lastResetDate != today) {
      // Se a data do último reset não for hoje, resete as refeições
      setState(() {
        refeicoes = List<Refeicao>.generate(
            numRef,
            (_) =>
                Refeicao()); // numRef deve ser atualizado a partir do Firebase
      });

      // Atualize a data do último reset para hoje
      await prefs.setString('lastResetDate', today);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      checkAndResetRefeicoes();
    });
  }



  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Assegura que userId não seja nulo antes de prosseguir
    if (userId == null) {
      // Retorne um widget de erro ou redirecionamento aqui
      return const Scaffold(
        body: Center(child: Text("Usuário não identificado.")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto os dados estão carregando, exibe um indicador de carregamento
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          // Se não houver dados, retorna um widget de erro ou um texto informativo
          return const Scaffold(
            body: Center(child: Text("Dados do usuário não disponíveis.")),
          );
        }

        // Se houver dados disponíveis, processa-os
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String userName = userData['nome'] ?? 'Usuário';

        // Construção do layout principal com os dados atualizados
        return Scaffold(
          appBar: AppBar(
            title: const Text("Revolution Nutri"),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Menu',
                        style: TextStyle(
                          color: Color.fromARGB(255, 51, 44,
                              44), // Escolha uma cor que combine com o fundo
                          fontSize: 24, // Ou o tamanho que você preferir
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 51, 44, 44),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.brightness_6),
                        onPressed: () {
                          Provider.of<ThemeNotifier>(context, listen: false)
                              .toggleTheme();
                        },
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Perfil'),
                  onTap: () {
                    print(
                        'Definindo MealGoal na HomePage: Protein ${singleMealGoal.totalProtein}, Carbs ${singleMealGoal.totalCarbs}, Fats ${singleMealGoal.totalFats}');

                    Navigator.pop(context); // Fecha o Drawer
                    // Navigator.pushNamed(
                    //     context, '/profile'); // Navega para a página de perfil
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () async {
                    // Fecha o Drawer
                    Navigator.pop(context);

                    // Desloga o usuário
                    await FirebaseAuth.instance.signOut();

                    // Verifica se o widget ainda está montado antes de prosseguir
                    if (mounted) {
                      // Navega para a tela de login e remove todas as rotas anteriores
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (Route<dynamic> route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: AddRemoveFoodWidget(
            userId: userId,
            onFoodAdded: addFoodToRefeicao,
            mealGoal: singleMealGoal,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                NutritionProgress(
                  onUpdateNutrition: updateNutrition,
                  currentCalories: currentCalories,
                  currentProtein: currentProtein,
                  currentCarbs: currentCarbs,
                  currentFats: currentFats,
                  totalCalories: totalCalories,
                  totalProtein: totalProtein,
                  totalCarbs: totalCarbs,
                  totalFats: totalFats,
                ),
                const SizedBox(height: 20),
                MyExpansionPanelListWidget(
                  userId: userId,
                  refeicoes: refeicoes,
                  onRefeicaoUpdated: onRefeicaoUpdated,
                  totalDailyCalories: totalCalories,
                  totalDailyProtein: totalProtein,
                  totalDailyCarbs: totalCarbs,
                  totalDailyFats: totalFats,
                  numRef: numRef,
                  mealGoal: singleMealGoal,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
