import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'login.dart';


class FormsScreen extends StatefulWidget {
  final String formId;

  const FormsScreen({super.key, required this.formId});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> with SingleTickerProviderStateMixin {

  Future<List<dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client
        .from('questoesTreinamento')
        .select('*,questoes(questao)')
        .eq('codigoTreinamento', widget.formId)
        .order('codigoTreinamento', ascending: true);
  }

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text("Formulário:",
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
                                ListTile(
                                  title: Text("${pergunta['codigoTreinamento'].toString()} - ${pergunta['questoes']['questao'].toString()}"),
                                  textColor: Colors.white,
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
      ),
    );
  }
}