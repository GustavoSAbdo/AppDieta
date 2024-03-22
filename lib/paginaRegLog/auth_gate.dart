import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';

class CustomSignInScreen extends StatefulWidget {
  @override
  _CustomSignInScreenState createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends State<CustomSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tenta fazer login com o e-mail e senha fornecidos
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Se o login for bem-sucedido, navega para /home
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        // Trata erros de login, como senha incorreta ou usuário não encontrado
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Usuário não encontrado.';
            break;
          case 'wrong-password':
            errorMessage = 'Senha incorreta.';
            break;
          default:
            errorMessage = 'Ocorreu um erro ao fazer login.';
            break;
        }
        // Mostra um diálogo com o erro
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erro de login'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  // Adiciona sua lógica de validação de e-mail aqui
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  // Regex simples para validação de e-mail
                  if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                      .hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null; // Retorna null se o valor passar na validação
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true, // Oculta o texto
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Valida o formulário e prossegue com o login se estiver tudo certo
                  if (_formKey.currentState!.validate()) {
                    _signIn();
                  }
                },
                child: Text('Entrar'),
              ),
              SizedBox(height: 20),

              // Adiciona um link para a tela de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ainda não tem conta?"),
                  TextButton(
                    onPressed: () {
                      // Navega para a tela de registro
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    child: Text('Registre-se'),
                  ),                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
