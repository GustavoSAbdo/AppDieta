import 'package:complete/paginaHome/home.dart';
import 'package:complete/paginaRegLog/pag_registro_dois.dart';
import 'package:complete/paginaRegLog/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'paginaRegLog/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  String userId = FirebaseAuth.instance.currentUser!.uid;
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  CustomSignInScreen(),
      routes: {
        '/login': (context) =>  CustomSignInScreen(),
        '/home': (context) =>  HomePage(userId: userId),
        '/register': (context) =>  RegisterPage(),
        '/registerDois': (context) => RegistroParteDois()
      },
    );
  }
}
