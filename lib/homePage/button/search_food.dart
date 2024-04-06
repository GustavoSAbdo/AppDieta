import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchAndSelectFoodWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;
  final String nutrientDominant;

  SearchAndSelectFoodWidget(
      {Key? key, required this.onFoodSelected, required this.nutrientDominant})
      : super(key: key);

  @override
  _SearchAndSelectFoodWidgetState createState() =>
      _SearchAndSelectFoodWidgetState();
}

class _SearchAndSelectFoodWidgetState extends State<SearchAndSelectFoodWidget> {
  String searchQuery = '';
  List<Map<String, dynamic>> selectedFoods = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addFoodToSelected(Map<String, dynamic> foodData) {
    setState(() {
      selectedFoods.add(foodData);
      widget.onFoodSelected(foodData);
    });
    searchController.clear();
    searchQuery = '';
    FocusScope.of(context).unfocus();
  }

  void removeFoodAt(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Pesquisar Alimento',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: searchQuery.isEmpty
              ? ListView.builder(
                  itemCount: selectedFoods.length,
                  itemBuilder: (context, index) {
                    final food = selectedFoods[index];
                    return ListTile(
                      title: Text(food['nome']),
                      // subtitle: Text('Calorias: ${food['kcal'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => removeFoodAt(index),
                      ),
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('alimentos')
                      .where('dominantNutrient',
                          isEqualTo: widget.nutrientDominant)
                      .where('searchKeywords', arrayContains: searchQuery)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();

                    final results = snapshot.data!.docs
                        .where((doc) => doc
                            .get('nome')
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery))
                        .toList();

                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            results[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['nome']),
                          subtitle: Text('Calorias: ${data['kcal'].toStringAsFixed(2)}, Carboidrato: ${data['carboidrato'].toStringAsFixed(2)}, Proteina: ${data['proteina'].toStringAsFixed(2)}, Gordura: ${data['gordura'].toStringAsFixed(2)}, '),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addFoodToSelected(data),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
