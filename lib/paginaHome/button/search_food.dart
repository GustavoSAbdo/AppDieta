import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchAndSelectFoodWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;

  SearchAndSelectFoodWidget({Key? key, required this.onFoodSelected}) : super(key: key);

  @override
  _SearchAndSelectFoodWidgetState createState() => _SearchAndSelectFoodWidgetState();
}

class _SearchAndSelectFoodWidgetState extends State<SearchAndSelectFoodWidget> {
  String searchQuery = '';
  List<Map<String, dynamic>> selectedFoods = [];

  void addFoodToSelected(Map<String, dynamic> foodData) {
  setState(() {
    
    selectedFoods.add(foodData);
    
    widget.onFoodSelected(foodData);
  });
}
 

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
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
                    return ListTile(
                      title: Text(selectedFoods[index]['nome']),
                      subtitle: Text('Calorias: ${selectedFoods[index]['kcal']}'),
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('alimentos')
                      .where('searchKeywords', arrayContains: searchQuery)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();

                    final results = snapshot.data!.docs.where((doc) => doc.get('nome').toString().toLowerCase().contains(searchQuery)).toList();

                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = results[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['nome']),
                          subtitle: Text('Calorias: ${data['kcal']}'),
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