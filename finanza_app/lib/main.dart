import 'package:flutter/material.dart';

import 'pages/welcome_page.dart';
import 'pages/register_page.dart';
import 'pages/account_type_page.dart';
import 'pages/register_step2_page.dart';
import 'pages/financial_info_page.dart';

// 👇 LOGIN + HOME
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 puedes dejar esto así por ahora
      initialRoute: '/',

      routes: {
        '/': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/account_type': (context) => const AccountTypePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },

      onGenerateRoute: (settings) {
        // 🔥 STEP 2
        if (settings.name == '/register_step2') {
          final accountType = settings.arguments as String? ?? "personal";

          return MaterialPageRoute(
            builder: (context) => RegisterStep2Page(accountType: accountType),
          );
        }

        // 🔥 FINANCIAL INFO
        if (settings.name == '/financial_info') {
          final accountType = settings.arguments as String? ?? "personal";

          return MaterialPageRoute(
            builder: (context) => FinancialInfoPage(accountType: accountType),
          );
        }

        // 🔥 fallback (evita crashes raros)
        return MaterialPageRoute(builder: (context) => const WelcomePage());
      },
    );
  }
}
