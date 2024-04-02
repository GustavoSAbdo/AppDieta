import 'package:complete/firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/paginaHome/hive/hive_food_item.dart';
import 'package:complete/paginaHome/hive/hive_refeicao.dart';

late Box<HiveFoodItem> foodBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(HiveFoodItemAdapter());
  Hive.registerAdapter(HiveRefeicaoAdapter());

  foodBox = await Hive.openBox<HiveFoodItem>('foodBox');
  final refeicaoBox = await Hive.openBox<HiveRefeicao>('refeicaoBox');

  runApp(
    Provider<Box<HiveRefeicao>>.value(
      value: refeicaoBox,
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    ),
  );
}

