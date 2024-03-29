import 'package:complete/firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/paginaHome/user_food_item.dart';

late Box<FoodItem> foodBox;
//TODO(codelab user): Get API key
const clientId = 'YOUR_CLIENT_ID';

void main() async {
  Hive.registerAdapter(FoodItemAdapter());
  await Hive.initFlutter();
  foodBox = await Hive.openBox<FoodItem>('foodBox');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

