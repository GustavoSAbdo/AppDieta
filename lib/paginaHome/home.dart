import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calorie_tracker.dart';
import 'panel_list.dart';
import 'button/button_widget.dart';
import 'adcionar_alimentos_bd/add_widget_bd.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  

  

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      super.initState();
      fetchUserData();
    }
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
        });
      }
    }
  }


  
  @override
  Widget build(BuildContext context) {
    String userName = userData?['nome'] ?? 'Usuário';
    String? userId = FirebaseAuth.instance.currentUser!.uid;    
    
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
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.pushNamed(
                    context, '/profile'); // Navega para a página de perfil
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
      floatingActionButton: AddFoodWidget(),
      body: SingleChildScrollView( // Permite rolar a tela se o conteúdo exceder a altura da tela.
        child: Column(
          children: <Widget>[
            NutritionProgress(userId: userId),
            MyExpansionPanelListWidget(userId: userId)            
          ],
        ),
      ),
    );
  }
}