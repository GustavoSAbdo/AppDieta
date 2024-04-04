import 'package:complete/homePage/home.dart';
import 'package:complete/regLogPage/pag_registro_dois.dart';
import 'package:complete/regLogPage/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'regLogPage/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: notifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
            home: CustomSignInScreen(),
            routes: {
              '/login': (context) => CustomSignInScreen(),
              '/home': (context) {
                String? userId = FirebaseAuth.instance.currentUser?.uid;
                return userId != null
                    ? HomePage(userId: userId)
                    : CustomSignInScreen();
              },
              '/register': (context) => RegisterPage(),
              '/registerDois': (context) => RegistroParteDois()
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'), // Português do Brasil
            ],
          );
        },
      ),
    );
  }
}
