import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodWidget extends StatefulWidget {
  @override
  _AddFoodWidgetState createState() => _AddFoodWidgetState();
}

class _AddFoodWidgetState extends State<AddFoodWidget> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  double _kcal = 0.0;
  double _proteina = 0.0;
  double _carboidrato = 0.0;
  double _gordura = 0.0;

  void _addFood() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('alimentos').add({
        'nome': _nome,
        'kcal': _kcal,
        'proteina': _proteina,
        'carboidrato': _carboidrato,
        'gordura': _gordura,
      }); // Fecha o popup após adicionar o alimento
    }
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Alimento'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome'),
                    onSaved: (value) => _nome = value ?? '',
                  ),                  
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Kcal'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _kcal = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Proteína (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _proteina = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Carboidrato (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _carboidrato = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Gordura (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _gordura = double.tryParse(value!) ?? 0.0,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: _addFood,
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Alimento"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
