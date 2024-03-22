import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroParteDois extends StatefulWidget {
  @override
  _RegistroParteDoisState createState() => _RegistroParteDoisState();
}

class _RegistroParteDoisState extends State<RegistroParteDois> {
  int _numRefeicoes = 2;
  String _nivelAtividade = '';
  String _objetivo = '';



  void _showObjetivoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione seu objetivo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RadioListTile<String>(
                  title: Text('Perder peso'),
                  value: 'perderPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('Manter peso'),
                  value: 'manterPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: Text('Ganhar peso'),
                  value: 'ganharPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAtividadeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione seu nível de atividade física'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('Sedentário'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'sedentario';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Atividade Leve(Atividade leve 3-5 vezes por semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'atividadeLeve';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Atividade Moderada(Atividade moderada 3-5 vezes por semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'atividadeModerada';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Muito Ativo(atividade pesada de 6-7 dias na semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'muitoAtivo';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Extremamente Ativo(Trabalho braçal mais atividade pesada ou atividade pesada 2x ao dia)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'extremamenteAtivo';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double calcularTMB(String genero, double peso, double altura, int idade) {
  if (genero == 'masculino') {
    return 66 + (13.8 * peso) + (5.0 * altura) - (6.8 * idade);
  } else {
    return 655 + (9.6 * peso) + (1.9 * altura) - (4.7 * idade);
  }
}


  Future<void> _cadastrarDados() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Pega os dados necessários do usuário
      String genero = userData['genero'];
      double peso = double.parse(userData['peso'].toString());
      double altura = double.parse(userData['altura'].toString());
      int idade = int.parse(userData['idade'].toString());

      // Calcula o TMB
      double tmb = calcularTMB(genero, peso, altura, idade);

      // Atualiza os dados no Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'tmb': tmb,
        'numRefeicoes': _numRefeicoes,
        'nivelAtividade': _nivelAtividade,
        'objetivo': _objetivo,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados cadastrados com sucesso!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar dados: $error')),
        );
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro - Parte 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantas refeições você quer fazer por dia?'),
            Slider(
              min: 2,
              max: 7,
              divisions: 5,
              label: '$_numRefeicoes',
              value: _numRefeicoes.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _numRefeicoes = value.toInt();
                });
              },
            ),
            SizedBox(height: 20),
            Text('Nível de atividade física:'),
            ElevatedButton(
              onPressed: _showAtividadeDialog,
              child: Text(
                  _nivelAtividade.isEmpty ? 'Selecionar' : _nivelAtividade),
            ),
            SizedBox(height: 20),
            Text('Objetivo:'),
            ElevatedButton(
              onPressed: _showObjetivoDialog,
              child: Text(_objetivo.isEmpty
                  ? 'Selecionar Objetivo'
                  : 'Objetivo: $_objetivo'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(
                    16.0), // Ajuste o padding conforme necessário
                child: ElevatedButton(
                  onPressed: _cadastrarDados,
                  child: Text('Cadastrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
