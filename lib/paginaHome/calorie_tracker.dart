import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionProgress extends StatefulWidget {
  final String userId;
  NutritionProgress({required this.userId});
  @override
  _NutritionProgressState createState() => _NutritionProgressState();
}

class _NutritionProgressState extends State<NutritionProgress> {
  double totalCalories = 0; // O total de calorias definido pelo usuário
  double currentCalories = 1900; // As calorias atuais consumidas
  double totalProtein = 0; // O total de proteína definido pelo usuário
  double currentProtein = 55; // A proteína atual consumida
  double totalCarbs = 0; // O total de carboidratos definido pelo usuário
  double currentCarbs = 90; // Os carboidratos atuais consumidos
  double totalFats = 0; // O total de gorduras definido pelo usuário
  double currentFats = 30; // As gorduras atuais consumidas

  void updateNutrition(int calories, int protein, int carbs, int fats) {
    setState(() {
      currentCalories += calories;
      currentProtein += protein;
      currentCarbs += carbs;
      currentFats += fats;
    });
  }

  void removeNutrition(int calories, int protein, int carbs, int fats) {
    setState(() {
      currentCalories = (currentCalories - calories).clamp(0, totalCalories);
      currentProtein = (currentProtein - protein).clamp(0, totalProtein);
      currentCarbs = (currentCarbs - carbs).clamp(0, totalCarbs);
      currentFats = (currentFats - fats).clamp(0, totalFats);
    });
  }

  Widget _buildProgressBar(String label, double currentValue, double totalValue, Color color) {
    double percent = currentValue / totalValue;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 6),
      child: Column(
        children: [
          Text(
            '$label: ${currentValue.toStringAsFixed(1)} / ${totalValue.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 16),
          ),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ],
      ),
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
          var userNutrition = snapshot.data!.data() as Map<String, dynamic>;
          double tmb = double.tryParse(userNutrition['tmb'].toString()) ?? 0;
          double peso = userNutrition['peso'] is double
              ? userNutrition['peso']
              : double.tryParse(userNutrition['peso'].toString()) ?? 0;
          totalFats = peso * 1;
          double coeficiente = 1;

          if (userNutrition['objetivo'] == 'perderPeso') {
            coeficiente = 0.8;
          } else if (userNutrition['objetivo'] == 'ganharPeso') {
            coeficiente = 1.2;
          } else {}

          if (userNutrition['nivelAtividade'] == 'sedentario') {
            totalCalories = (tmb * 1) * coeficiente;
            totalProtein = peso * 1;
            totalCarbs =
                (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;
          } else if (userNutrition['nivelAtividade'] == 'atividadeLeve') {
            totalCalories = (tmb * 1.2) * coeficiente;
            totalProtein = peso * 1.2;
            totalCarbs =
                (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;
          } else if (userNutrition['nivelAtividade'] == 'atividadeModerada') {
            totalCalories = (tmb * 1.4) * coeficiente;
            totalProtein = peso * 1.5;
            totalCarbs =
                (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;
          } else if (userNutrition['nivelAtividade'] == 'muitoAtivo') {
            totalCalories = (tmb * 1.6) * coeficiente;
            totalProtein = peso * 2;
            totalCarbs =
                (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;
          } else {
            totalCalories = (tmb * 1.8) * coeficiente;
            totalProtein = peso * 2.2;
            totalCarbs = 0;
            totalCarbs =
                (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 20,
                        ),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 80,
                            startDegreeOffset: 270, // Ajuste para meia lua
                            sections: [
                              PieChartSectionData(
                                color: Colors.blueAccent,
                                value: (currentCalories / totalCalories) * 100, 
                                title: '',
                                radius: 30,
                              ),
                              PieChartSectionData(
                                color: Color.fromARGB(123, 240, 240, 240),
                                value: 100 - (currentCalories / totalCalories) * 100, // Completa o círculo
                                title: '',
                                radius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Calorias\n${currentCalories.toStringAsFixed(1)}/${totalCalories.toStringAsFixed(1)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildProgressBar(
                  'Proteínas',
                  currentProtein,
                  totalProtein,
                  Colors.green,
                ),),
                _buildProgressBar(
                  'Carboidratos',
                  currentCarbs,
                  totalCarbs,
                  Colors.red,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildProgressBar(
                    'Gorduras',
                    currentFats,
                    totalFats,
                  Colors.orange,
                  ),
                )
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Quando os dados estão sendo carregados...
          return const Center(child: CircularProgressIndicator());
        } else {
          // Para outros estados, como erro ou dados não encontrados
          return const Center(child: Text("Não foi possível carregar os dados."));
        }
      },
    );
  }
}
