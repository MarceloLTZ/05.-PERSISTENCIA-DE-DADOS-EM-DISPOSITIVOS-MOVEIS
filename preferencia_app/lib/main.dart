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
  
  // Exercício 02: Variável para controlar o tamanho da fonte
  double _tamanhoFonte = 14.0;
  
  // Exercício 03: Variável para controlar o switch de notificações
  bool _receberNotificacoes = false;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  // Carrega todas as preferências salvas
  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeSalvo = prefs.getString('usuario_nome') ?? 'Não informado';
      _nomeController.text = prefs.getString('usuario_nome') ?? '';
      
      // Exercício 02: Carrega o tamanho da fonte (padrão: 14.0 - Médio)
      _tamanhoFonte = prefs.getDouble('tamanho_fonte') ?? 14.0;
      
      // Exercício 03: Carrega a preferência de notificações (padrão: false)
      _receberNotificacoes = prefs.getBool('receber_notificacoes') ?? false;
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

  // Exercício 02: Salva o tamanho da fonte selecionado
  Future<void> _salvarTamanhoFonte(double tamanho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tamanho_fonte', tamanho);
    setState(() {
      _tamanhoFonte = tamanho;
    });
  }

  // Exercício 03: Salva o estado do switch de notificações
  Future<void> _salvarNotificacoes(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receber_notificacoes', valor);
    setState(() {
      _receberNotificacoes = valor;
    });
  }

  // Exercício 01: Limpa todas as configurações gravadas
  Future<void> _limparConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reseta o tema para o valor padrão (claro)
    widget.onTemaAlterado(false);

    // Atualiza o estado da tela para os valores padrão
    setState(() {
      _nomeController.clear();
      _nomeSalvo = 'Não informado';
      _tamanhoFonte = 14.0;
      _receberNotificacoes = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as configurações foram limpas!'),
          backgroundColor: Colors.orange,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuração do Tema
            Card(
              child: SwitchListTile(
                title: Text('Modo Escuro', style: TextStyle(fontSize: _tamanhoFonte)),
                subtitle: Text('Ativar visual escuro na aplicação', style: TextStyle(fontSize: _tamanhoFonte * 0.85)),
                secondary: Icon(_temaEscuroIcone()),
                value: widget.temaEscuro,
                onChanged: widget.onTemaAlterado,
              ),
            ),
            const SizedBox(height: 10),

            // Exercício 03: Switch de Receber Notificações
            Card(
              child: SwitchListTile(
                title: Text('Receber Notificações', style: TextStyle(fontSize: _tamanhoFonte)),
                subtitle: Text('Permitir notificações do aplicativo', style: TextStyle(fontSize: _tamanhoFonte * 0.85)),
                secondary: const Icon(Icons.notifications),
                value: _receberNotificacoes,
                onChanged: _salvarNotificacoes,
              ),
            ),
            const SizedBox(height: 10),

            // Exercício 02: Seleção de Tamanho da Fonte
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamanho da Fonte',
                      style: TextStyle(fontSize: _tamanhoFonte, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<double>(
import 'package:flutter/material.dart';
                      segments: const [
                        ButtonSegment<double>(
                          value: 12.0,
                          label: Text('Pequeno'),
                          icon: Icon(Icons.text_fields, size: 16),
                        ),
                        ButtonSegment<double>(
                          value: 14.0,
                          label: Text('Médio'),
                          icon: Icon(Icons.text_fields, size: 20),
                        ),
                        ButtonSegment<double>(
                          value: 18.0,
                          label: Text('Grande'),
                          icon: Icon(Icons.text_fields, size: 24),
                        ),
                      ],
                      selected: {_tamanhoFonte},
                      onSelectionChanged: (Set<double> novaSelecao) {
                        _salvarTamanhoFonte(novaSelecao.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Perfil do Usuário
            Text(
              'Perfil do Usuário',
              style: TextStyle(fontSize: _tamanhoFonte + 4, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nomeController,
              style: TextStyle(fontSize: _tamanhoFonte),
              decoration: InputDecoration(
                labelText: 'Nome do Usuário',
                labelStyle: TextStyle(fontSize: _tamanhoFonte),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvarNome,
                icon: const Icon(Icons.save),
                label: Text('Salvar Nome', style: TextStyle(fontSize: _tamanhoFonte)),
              ),
            ),
            const Divider(height: 40),

            // Exibição dos dados salvos
            Text(
              'Valor atual salvo no disco: $_nomeSalvo',
              style: TextStyle(fontSize: _tamanhoFonte, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),

            // Exercício 01: Botão para limpar configurações
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: _limparConfiguracoes,
                icon: const Icon(Icons.delete_forever),
                label: Text('Limpar Configurações', style: TextStyle(fontSize: _tamanhoFonte)),
              ),
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
