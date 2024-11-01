import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:innovacheck/cadastro.dart';
import 'package:innovacheck/menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'forms.dart';
import 'formulario.dart';
import 'login.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const CadastroTreinamento(),
    ),
    GoRoute(
      path: '/editar',
      builder: (context, state) => const FormularioTreinamento(),
    ),
    GoRoute(
      path: '/form/:id',
      builder: (context, state) {
        final formId = state.pathParameters['id']!;
        return FormsScreen(formId: formId);
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pimcserptocmnpgyvjya.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpbWNzZXJwdG9jbW5wZ3l2anlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMyMDIxOTUsImV4cCI6MjAzODc3ODE5NX0.BBIkUbPIMqK8QkFlbnJkk_woBk2wkl_LfBNYd0X9Yio',
  );
  runApp(MaterialApp.router(
    routerConfig: _router,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '(in)nova check',
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.white,
          //Color: Colors.indigo.withOpacity(0.4),
          //backgroundColor: Colors.grey[900]!,
          // Cor de fundo principal do tema escuro
          brightness: Brightness.dark,
          errorColor: Colors.red,
        ),
      ),
      themeMode: ThemeMode.dark,
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
