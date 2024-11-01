import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'login.dart';
import 'menu.dart';

class FormularioTreinamento extends StatefulWidget {
  const FormularioTreinamento({super.key});

  @override
  State<FormularioTreinamento> createState() => _FormularioTreinamentoState();
}

class _FormularioTreinamentoState extends State<FormularioTreinamento> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para os campos
  final TextEditingController nomeTreinamentoController = TextEditingController();
  final TextEditingController instrutorTreinamentoController = TextEditingController();
  final TextEditingController questaoController = TextEditingController();
  final TextEditingController dataInicialController = TextEditingController();
  final TextEditingController dataFinalController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  Future<List<dynamic>>? _future;
// Map para armazenar o estado dos checkboxes
  Map<int, bool> checkedItems = {};
  Set<int> checkedQuestoes = {};
  int? _selectedValue; // 1 para Satisfação, 2 para Conformidade

  @override
  void initState() {
    super.initState(); // Mova esta linha para o início do método
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await obterDados();
    });
  }

  // Função para alternar a seleção
  void _onCheckboxChanged(int value) {
    setState(() {
      _selectedValue = value;
    });
  }

  Future<void> obterDados() async {
    final response = await supabase
        .from('treinamento')
        .select('nomeTreinamento, dataInicial, dataFinal, instrutor')
        .eq('codigoTreinamento', codTreinamento)
        .order('codigoTreinamento', ascending: true)
        .maybeSingle();

    // Busca os itens do 'questoesTreinamento' e adiciona os codigoQuestoes a uma lista
    final response2 = await supabase
        .from('questoesTreinamento')
        .select('*')
        .eq('codigoTreinamento', codTreinamento)
        .order('codigoTreinamento', ascending: true);

    // Armazena os codigoQuestoes encontrados para marcar os checkboxes
    checkedQuestoes = response2
        .map((questao) => questao['codigoQuestoes'] as int)
        .toSet();

    // Armazena o _future com a lista de questoes
    // Armazena o _future com a lista de questoes
    _future = Supabase.instance.client
        .from('questoes')
        .select('*, tipoquestao(descricao)')
        .order('codigoQuestoes', ascending: true)
        .then((result) => result as List<dynamic>);


    // Atualiza os campos do formulário se houver dados em response
    if (response != null) {
      setState(() {
        nomeTreinamentoController.text = response['nomeTreinamento']?.toString() ?? '';
        instrutorTreinamentoController.text = response['instrutor']?.toString() ?? '';
        dataInicialController.text = response['dataInicial']?.toString() ?? '';
        dataFinalController.text = response['dataFinal']?.toString() ?? '';
      });
    }
  }

  // Função para selecionar datas
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  // Função para cadastrar o treinamento no Supabase
  Future<void> _editarTreinamento() async {
    if (_formKey.currentState!.validate()) {
      // Atualiza o registro onde codigoTreinamento é igual a codTreinamento
      final response = await supabase
          .from('treinamento')
          .update({
        'nomeTreinamento': nomeTreinamentoController.text,
        'instrutor': instrutorTreinamentoController.text,
        'codigoEmpresa': codEmpresa,
        'dataInicial': dataInicialController.text,
        'dataFinal': dataFinalController.text,
      }).eq('codigoTreinamento', codTreinamento); // Filtra pelo codigoTreinamento

      if (kDebugMode) {
        print(response);
      }
      // Verifica se a resposta é nula ou contém erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento atualizado com sucesso!')),
        );
      } else {
        // Caso response seja nulo
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: resposta nula.')),
        );
      }
    }
  }


  Future<void> _cadastrarQuestao() async {
    if (questaoController.text.isNotEmpty && _selectedValue != null) {
      final response = await Supabase.instance.client
          .from('questoes')
          .insert({
        'questao': questaoController.text,
        'codigoAdministrador': codUsuario,
        'tipoQuestao': _selectedValue
      });
      await obterDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastrado!')),
        );
        // Limpar os campos
        questaoController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.error!.message}')),
        );
      }
    }
  }

  Future<void> _marcarQuestao(codigoQuestoes, codigoTreinamento) async {
      final response = await Supabase.instance.client
          .from('questoesTreinamento')
          .insert({
        'codigoQuestoes': codigoQuestoes,
        'codigoTreinamento': codigoTreinamento
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marcado!')),
        );
        // Limpar os campos
        questaoController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.error!.message}')),
        );
      }
  }

  Future<void> _desmarcarQuestao(codigoQuestoes, codigoTreinamento) async {
      final response = await Supabase.instance.client
          .from('questoesTreinamento')
          .delete()
          .eq('codigoQuestoes', codigoQuestoes)
          .eq('codigoTreinamento', codigoTreinamento);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Desmarcado!')),
        );
        // Limpar os campos
        questaoController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.error!.message}')),
        );
      }
  }

  Future<void> _removerQuestao(codigoQuestoes) async {
    if (!checkedQuestoes.contains(codigoQuestoes)) {
      // Questão não está marcada, então pode remover
      final response = await Supabase.instance.client
          .from('questoes')
          .delete()
          .eq('codigoAdministrador', codUsuario)
          .eq('codigoQuestoes', codigoQuestoes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Questão removida!')),
        );
        await obterDados();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.error!.message}')),
        );
      }
    } else {
      // Se a questão está marcada, peça ao usuário para desmarcá-la primeiro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desmarque a questão antes de removê-la.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Editar treinamento:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: nomeTreinamentoController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Nome',
                  labelStyle: const TextStyle(
                      color: Colors.white
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do treinamento';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: instrutorTreinamentoController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Instrutor',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, preencha um instrutor.';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: dataInicialController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Data Inicial',
                  labelStyle: const TextStyle(
                      color: Colors.white
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today,
                      color: Colors.white,),
                    onPressed: () => _selectDate(context, dataInicialController),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data inicial';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: dataFinalController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Data Final',
                  labelStyle: const TextStyle(
                      color: Colors.white
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today,
                      color: Colors.white,),
                    onPressed: () => _selectDate(context, dataFinalController),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data final';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Adicionar Questões:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: questaoController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white),
                  labelText: 'Questão',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, preencha a questão.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (!states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return null;
                    }),
                    checkColor: Colors.white,
                    activeColor: Colors.grey.shade800,
                    side: const BorderSide(color: Colors.white, width: 2),
                    value: _selectedValue == 1,
                    onChanged: (bool? newValue) {
                      if (newValue == true) {
                        _onCheckboxChanged(1); // Satisfação selecionada
                      } else {
                        setState(() => _selectedValue = null); // Desmarcar
                      }
                    },
                  ),
                  const Text('Satisfação',
                    style: TextStyle(
                        color: Colors.white
                    ),),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: _selectedValue == 2,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (!states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return null;
                    }),
                    checkColor: Colors.white,
                    activeColor: Colors.grey.shade800,
                    side: const BorderSide(color: Colors.white, width: 2),
                    onChanged: (bool? newValue) {
                      if (newValue == true) {
                        _onCheckboxChanged(2); // Conformidade selecionada
                      } else {
                        setState(() => _selectedValue = null); // Desmarcar
                      }
                    },
                  ),
                  const Text('Conformidade',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                  Checkbox(
                    value: _selectedValue == 3,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (!states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return null;
                    }),
                    checkColor: Colors.white,
                    activeColor: Colors.grey.shade800,
                    side: const BorderSide(color: Colors.white, width: 2),
                    onChanged: (bool? newValue) {
                      if (newValue == true) {
                        _onCheckboxChanged(3); // Conformidade selecionada
                      } else {
                        setState(() => _selectedValue = null); // Desmarcar
                      }
                    },
                  ),
                  const Text('Texto',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,),
                onPressed: _cadastrarQuestao,
                child: const Text('Incluir'),
              ),
              const SizedBox(height: 20),
              const Text("Lista de Questões:",
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
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.7,
                    child: FutureBuilder<List<dynamic>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        } else if (snapshot.hasError) {
                          return Text("Erro: ${snapshot.error}",
                            style: const TextStyle(color: Colors.white),);
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text("Nenhum dado encontrado.",
                            style: const TextStyle(color: Colors.white),);
                        } else {
                          final data = snapshot.data!;
                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final questao = data[index];
                              final codigoQuestoes = questao['codigoQuestoes'] as int;
                              print(questao);
                              return InkWell(
                                onLongPress: () async {
                                  await _removerQuestao(codigoQuestoes);
                                },
                                child: ListTile(
                                  title: Text(
                                    "${index + 1} - ${questao['questao'].toString()}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    (questao['tipoquestao'] != null)
                                        ? questao['tipoquestao']['descricao'].toString()
                                        : 'Descrição não disponível',
                                    style: const TextStyle(color: Colors.white),
                                  ),

                                  trailing: Checkbox(
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (!states.contains(WidgetState.selected)) {
                                        return Colors.transparent;
                                      }
                                      return null;
                                    }),
                                    checkColor: Colors.white,
                                    activeColor: Colors.grey.shade800,
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    value: checkedQuestoes.contains(codigoQuestoes),
                                    onChanged: (bool? value) async {
                                        if (value == true) {
                                          setState(() {
                                            checkedQuestoes.add(codigoQuestoes);
                                          });
                                          if (kDebugMode) {
                                            print("Questão $codigoQuestoes marcada");
                                          }
                                          await _marcarQuestao(codigoQuestoes, codTreinamento);
                                        } else {
                                          setState(() {
                                            checkedQuestoes.remove(codigoQuestoes);
                                          });
                                          _desmarcarQuestao(codigoQuestoes, codTreinamento);
                                          if (kDebugMode) {
                                            print("Questão $codigoQuestoes desmarcada");
                                          }
                                        }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: "1",
              backgroundColor: Colors.white,
              onPressed: _editarTreinamento,
              child: const Icon(Icons.save),
          ),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              heroTag: "2",
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back_ios_new_sharp),
              onPressed: (){
                context.go('/menu');
              }
          ),
        ],
      ),
    );
  }
}
