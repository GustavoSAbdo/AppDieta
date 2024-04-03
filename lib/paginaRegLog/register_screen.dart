import 'dart:async';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:complete/paginaRegLog/custom_phone_input.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

enum Gender { masculino, feminino }

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController =
      MaskedTextController(mask: '000.000.000-00');
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Gender? _selectedGender;

  @override
  void dispose() {
    _dateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _celularController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  // ignore: unused_field
  String _phoneNumber = '';
  void _onPhoneChanged(PhoneNumber number) {
    // Ação quando o número de telefone é alterado
    setState(() {
      _phoneNumber = number.phoneNumber ?? '';
    });
  }

  Future<void> _registerUser() async {
    // Verifica se o gênero foi selecionado
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um gênero.')),
      );
      return;
    }

    try {
      // Cria um novo usuário com email e senha
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      await userCredential.user?.sendEmailVerification();
      // Recupera o UID do usuário recém-criado
      final String uid = userCredential.user!.uid;

      // Calcula a idade a partir da data de nascimento
      final DateTime today = DateTime.now();
      final DateTime birthDate =
          _selectedDate; // Supondo que _selectedDate seja a data de nascimento
      int idade = today.year - birthDate.year;
      if (birthDate.month > today.month ||
          (birthDate.month == today.month && birthDate.day > today.day)) {
        idade--;
      }

      // Salva os dados adicionais do usuário no Firestore usando UID como chave
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nome': _nomeController.text,
        'cpf': _cpfController.text,
        'celular': _celularController.text,
        'peso': _pesoController.text,
        'altura': _alturaController.text,
        'genero':
            _selectedGender == Gender.masculino ? 'masculino' : 'feminino',
        'idade': idade
      });

      // Registro bem-sucedido, exibe um AlertDialog
      if (mounted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registro bem-sucedido'),
                content: const Text('Sua conta foi criada com sucesso.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o AlertDialog
                      Navigator.pushReplacementNamed(context,
                          '/registerDois'); // Redireciona para a HomePage
                    },
                  )
                ],
              );
            });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' && mounted) {
        _showErrorDialog(
            'Erro', 'O email fornecido já está sendo usado por outra conta!');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<bool> cpfJaCadastrado(String cpf) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('cpf', isEqualTo: cpf)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  bool emailValido(String email) {
    final RegExp regexEmail = RegExp(
      r'^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return regexEmail.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite seu nome completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  // Verifica se o nome tem mais de um caractere
                  if (value.trim().length <= 3) {
                    return 'O nome deve ter mais de três caracteres';
                  }
                  // Verifica se o nome contém apenas letras e espaços
                  if (!RegExp(r"^[a-zA-Z\sáéíóúÁÉÍÓÚñÑ]+$").hasMatch(value)) {
                    return 'O nome deve conter apenas letras';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      CPFValidator.isValid(_cpfController.text) == false) {
                    return 'Por favor, insira um CPF válido!';
                  }
                  return null;
                },
              ),
              CustomPhoneInput(
                controller: _celularController,
                onInputChanged: (PhoneNumber number) {
                  _onPhoneChanged(number);
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true, // torna o campo de texto somente leitura
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua data de nascimento';
                  }
                  final DateFormat formatter = DateFormat('dd/MM/yyyy');
                  DateTime? birthDate;
                  try {
                    birthDate = formatter.parseStrict(value);
                  } catch (e) {
                    return 'Formato de data inválido. Use DD/MM/AAAA';
                  }
                  final DateTime today = DateTime.now();
                  final int age = today.year - birthDate.year;
                  if (birthDate.month > today.month ||
                      (birthDate.month == today.month &&
                          birthDate.day > today.day)) {
                    return 'Você deve ter pelo menos 12 anos';
                  }
                  if (age < 12) {
                    return 'Você deve ter pelo menos 12 anos';
                  }
                  // Retorna null se o valor passar na validação
                  return null;
                },
              ),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                    labelText: 'Peso (kg)', hintText: 'Digite seu peso atual'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu peso';
                  }
                  final peso = double.tryParse(value.replaceAll(',', '.'));
                  if (peso == null) {
                    return 'Por favor, insira um número válido';
                  } else if (peso < 15 || peso > 300) {
                    return 'O peso deve estar entre 15kg e 300kg';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _alturaController,
                decoration: const InputDecoration(
                    labelText: 'Altura (cm)', hintText: 'Digite sua altura'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua altura';
                  }
                  final altura = int.tryParse(value);
                  if (altura == null) {
                    return 'Por favor, insira um número válido!';
                  } else if (altura < 50 || altura > 300) {
                    return 'Altura inválida!';
                  }
                  return null;
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Masculino'),
                value: Gender.masculino,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Feminino'),
                value: Gender.feminino,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', hintText: 'Digite seu email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  } else if (!emailValido(_emailController.text)) {
                    return 'Por favor, insira um email válido!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    suffixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              // Adicionar os outros TextFormField aqui...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          '/login'); // Retorna à tela anterior
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool cpfCadastrado = await cpfJaCadastrado(
                            _cpfController.text
                                .replaceAll('.', '')
                                .replaceAll('-', ''));
                        if (cpfCadastrado) {
                          _showErrorDialog('Erro', 'CPF já cadastrado!');
                        } else {
                          _registerUser();
                        }
                      }
                    },
                    child: const Text('Registrar'),
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
