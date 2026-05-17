import 'package:flutter/material.dart';

import 'pages/welcome_page.dart';
import 'pages/register_page.dart';
import 'pages/account_type_page.dart';
import 'pages/register_step2_page.dart';
import 'pages/financial_info_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/income_page.dart';
import 'pages/debt_page.dart';
import 'pages/debts_page.dart';
import 'pages/perfil_page.dart';
import 'pages/expenses_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      routes: {
        '/': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/account_type': (context) => const AccountTypePage(),
        '/login': (context) => const LoginPage(),

        // HOME
        '/home': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return HomePage(email: email);
        },

        // INCOME
        '/income': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return IncomePage(email: email);
        },

        // DEBT FORM (agregar deuda)
        '/debt': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return DebtPage(email: email);
        },

        '/perfil': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return PerfilPage(email: email);
        },

        // LISTA DE DEUDAS (ver deudas)
        '/debts': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return DebtsPage(email: email);
        },

        '/expenses': (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ??
              "Usuario";

          return ExpensesPage(email: email);
        },
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/register_step2') {
          final accountType = settings.arguments as String? ?? "personal";

          return MaterialPageRoute(
            builder: (context) => RegisterStep2Page(accountType: accountType),
          );
        }

        if (settings.name == '/financial_info') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => FinancialInfoPage(
              accountType: args['accountType'],
              email: args['email'],
              password: args['password'],
            ),
          );
        }

        return MaterialPageRoute(builder: (context) => const WelcomePage());
      },
    );
  }
}
