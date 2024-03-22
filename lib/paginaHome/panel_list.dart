import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyExpansionPanelListWidget extends StatefulWidget {
  final String userId; // ID do usuário passado como parâmetro

  const MyExpansionPanelListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _MyExpansionPanelListWidgetState createState() => _MyExpansionPanelListWidgetState();
}

class _MyExpansionPanelListWidgetState extends State<MyExpansionPanelListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var numRef = userData['numRefeicoes'] ?? 0; // Assume um valor padrão caso não esteja definido
          List<int> _indexes = List.generate(numRef, (index) => index);

          return ExpansionPanelList.radio(
            children: _indexes.map((index) => ExpansionPanelRadio(
              value: index,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text('Refeição ${index+1}'),
                );
              },
              body: ListTile(
                title: Text('Conteúdo do Painel $index'),
                subtitle: Text('Detalhes do painel $index aqui.'),
              ),
            )).toList(),
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
