import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PreferenciaApp());
}

class PreferenciaApp extends StatefulWidget {
  const PreferenciaApp({super.key});

  @override
  State<PreferenciaApp> createState() => _PreferenciaAppState();
}

class _PreferenciaAppState extends State<PreferenciaApp> {
  bool _temaEscuro = false;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  // Carrega o tema salvo ao iniciar o app
  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaEscuro = prefs.getBool('isDark') ?? false;
    });
  }

  // Altera e salva o tema no disco
  Future<void> _alternarTema(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', valor);
    setState(() {
      _temaEscuro = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preferências do Usuário',
      debugShowCheckedModeBanner: false,
      theme: _temaEscuro ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: ConfigScreen(
        temaEscuro: _temaEscuro,
        onTemaAlterado: _alternarTema,
      ),
    );
  }
}

class ConfigScreen extends StatefulWidget {
  final bool temaEscuro;
  final ValueChanged<bool> onTemaAlterado;

  const ConfigScreen({
    super.key,
    required this.temaEscuro,
    required this.onTemaAlterado,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _nomeController = TextEditingController();
  String _nomeSalvo = '';

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeSalvo = prefs.getString('usuario_nome') ?? 'Não informado';
      _nomeController.text = prefs.getString('usuario_nome') ?? '';
    });
  }

  Future<void> _salvarNome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_nome', _nomeController.text.trim());
    setState(() {
      _nomeSalvo = _nomeController.text.trim();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome salvo localmente com sucesso!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações Locais'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Modo Escuro'),
                subtitle: const Text('Ativar visual escuro na aplicação'),
                secondary: Icon(_temaEscuroIcone()),
                value: widget.temaEscuro,
                onChanged: widget.onTemaAlterado,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Perfil do Usuário',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvarNome,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Nome'),
              ),
            ),
            const Divider(height: 40),
            Text(
              'Valor atual salvo no disco: $_nomeSalvo',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  IconData _temaEscuroIcone() {
    return widget.temaEscuro ? Icons.dark_mode : Icons.light_mode;
  }
}
