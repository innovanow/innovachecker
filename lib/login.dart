import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'menu.dart';

int codEmpresa = 0;
String empresa = "";
String nomeUsuario = "";
int codUsuario = 0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;


// Função de login com verificação na tabela 'usuarios'
  Future<void> _login() async {
    try {
      final username = _usernameController.text.toLowerCase();
      final password = _passwordController.text.toLowerCase();

      if (username.isNotEmpty && password.isNotEmpty) {
        // Query para buscar o usuário e senha na tabela 'usuarios'
        final response = await supabase
            .from('administradores')
            .select('codigoAdministrador, usuario, senha, codigoEmpresa, nome, empresa(empresa)')
            .eq('usuario', username)
            .eq('senha', password)
            .maybeSingle();

        if (response != null && response['usuario'] != null) {
          // Login bem-sucedido, salvar a empresa
          codEmpresa = response['codigoEmpresa'];
          codUsuario = response['codigoAdministrador'];
          nomeUsuario = response['nome'];
          final empresaData = response['empresa'];  // 'empresa' é o nome da relação
          empresa = empresaData['empresa'];
          if (kDebugMode) {
            print('Login successful! Empresa: $codEmpresa');
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          if (!mounted) return;
          context.go('/menu');

          // Aqui você pode redirecionar para outra tela ou salvar os dados da empresa no estado global
        } else {
          // Usuário ou senha incorretos
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Usuário ou senha incorretos $response')),
          );
        }
      } else {
        // Campos vazios
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, insira o usuário e a senha')),
        );
      }
    } catch (e) {
      // Capturar erros
      if (kDebugMode) {
        print('Erro: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/logo.png',
                height: 100,),
              const Text("Área do Administrador",
              style: TextStyle(
                color: Colors.white
              ),),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _usernameController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Usuário',
                  labelStyle: const TextStyle(
                    color: Colors.white
                ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Senha',
                  labelStyle: const TextStyle(
                      color: Colors.white
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,),
                  onPressed: _login,
                  child: const Text('Login',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}