import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'cadastro.dart';
import 'formulario.dart';
import 'login.dart';

int codTreinamento = 0;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {

  Future<List<dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client
        .from('treinamento')
        .select('*, empresa(empresa)')
        .eq('codigoEmpresa', codEmpresa) // Filtra pelo codigo da empresa
        .order('codigoTreinamento', ascending: true);
  }

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 80,
              color: Colors.deepPurple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/logo.png',
                    height: 50,),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(nomeUsuario,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                      Text(empresa,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w100,
                          )),
                    ],
                  ),
                  IconButton(
                    color: Colors.white,
                    onPressed: (){
                    context.go('/login');
                  },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Listagem:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            FadeInUp(
              duration: const Duration(milliseconds: 1600),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Define o raio das bordas
                  ),
                  height: MediaQuery.of(context).size.height - 200,
                  child: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final perguntas = snapshot.data!;
                      return ListView.builder(
                        itemCount: perguntas.length,
                        itemBuilder: ((context, index) {
                          final pergunta = perguntas[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: (){
                                  codTreinamento = pergunta['codigoTreinamento'];
                                  context.go('/editar');
                                },
                                child: ListTile(
                                  title: Text("${pergunta['codigoTreinamento'].toString()} - ${pergunta['nomeTreinamento'].toString()}"),
                                  textColor: Colors.white,
                                  trailing: IconButton(
                                    tooltip: "${pergunta['codigoTreinamento']}",
                                    onPressed: (){
                                      context.go('/form/${pergunta['codigoTreinamento']}');
                                    }, icon: const Icon(Icons.remove_red_eye,
                                  color: Colors.white,),),
                                ),
                              ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: (){
            context.go('/cadastro');
          }
      ),
    );
  }
}