import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchFoodWidget extends StatefulWidget {
  @override
  _SearchFoodWidgetState createState() => _SearchFoodWidgetState();
}

class _SearchFoodWidgetState extends State<SearchFoodWidget> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
          child: StreamBuilder<QuerySnapshot>(
            stream: (searchQuery == "")
                ? FirebaseFirestore.instance.collection('alimentos').snapshots()
                : FirebaseFirestore.instance
                    .collection('alimentos')
                    .where('nome', isGreaterThanOrEqualTo: searchQuery)
                    .where('nome', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              return ListView(
                children: snapshot.data!.docs.map((document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['nome']),
                    subtitle: Text('Proteínas: ${data['proteinas']}g, Carboidratos: ${data['carboidratos']}g, Gorduras: ${data['gorduras']}g'),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}