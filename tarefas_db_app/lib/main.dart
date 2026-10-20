import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/tarefa.dart';

void main() {
  runApp(const TarefasDbApp());
}

class TarefasDbApp extends StatelessWidget {
  const TarefasDbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas SQLite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const TarefasScreen(),
    );
  }
}

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  List<Tarefa> _tarefas = [];
  bool _carregando = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // EXERCÍCIO 03: Atualiza a lista filtrando pelo termo pesquisado ou buscando tudo
  Future<void> _atualizarLista() async {
    setState(() => _carregando = true);
    
    final termo = _searchController.text.trim();
    final List<Tarefa> dados;

    if (termo.isEmpty) {
      dados = await DatabaseHelper.instance.queryAll();
    } else {
      dados = await DatabaseHelper.instance.searchByTitulo(termo);
    }

    setState(() {
      _tarefas = dados;
      _carregando = false;
    });
  }

  Future<void> _adicionarTarefa(String titulo) async {
    if (titulo.trim().isEmpty) return;
    await DatabaseHelper.instance.insert(Tarefa(titulo: titulo.trim()));
    _atualizarLista();
  }

  Future<void> _alternarStatus(Tarefa tarefa) async {
    final atualizada = tarefa.copyWith(concluida: !tarefa.concluida);
    await DatabaseHelper.instance.update(atualizada);
    _atualizarLista();
  }

  Future<void> _removerTarefa(int id) async {
    await DatabaseHelper.instance.delete(id);
    _atualizarLista();
  }

  // EXERCÍCIO 02: Limpar todas as tarefas do banco com confirmação
  Future<void> _limparTodasTarefas() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todas as tarefas?'),
        content: const Text('Esta ação excluirá permanentemente todos os registros do banco de dados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.deleteAll();
      _searchController.clear();
      _atualizarLista();
    }
  }

  void _exibirDialogCadastro() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tarefa (SQLite)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Descrição da tarefa',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _adicionarTarefa(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistência Relacional (SQLite)'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // EXERCÍCIO 02: Botão de ação na AppBar para limpar tudo
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpar tudo',
            onPressed: _limparTodasTarefas,
          ),
        ],
      ),
      body: Column(
        children: [
          // EXERCÍCIO 03: Campo de Busca por Texto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar tarefa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _atualizarLista();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _atualizarLista(),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _tarefas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma tarefa encontrada.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tarefas.length,
                        itemBuilder: (ctx, i) {
                          final t = _tarefas[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: Checkbox(
                                value: t.concluida,
                                onChanged: (_) => _alternarStatus(t),
                              ),
                              title: Text(
                                t.titulo,
                                style: TextStyle(
                                  decoration: t.concluida
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: t.concluida ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerTarefa(t.id!),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // EXERCÍCIO 01: Contador no Rodapé
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal.shade50,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            'Total de tarefas: ${_tarefas.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exibirDialogCadastro,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
