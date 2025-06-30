import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/categoria_servicos.dart';

class EditarServico extends StatefulWidget {
  final String servicoId;

  const EditarServico({Key? key, required this.servicoId}) : super(key: key);

  @override
  State<EditarServico> createState() => _EditarServicoState();
}

class _EditarServicoState extends State<EditarServico> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  // Campos para edição
  String categoria = '';
  List<Map<String, dynamic>> produtos = [];

  double valorTaxa = 0;
  double valorVendas = 0;
  double despesas = 0;
  double lucroEstim = 0;

  bool vincularEventoInterno = false;
  String? eventoIdSelecionado;
  String? eventoNomeSelecionado;

  final TextEditingController nomeProdutoController = TextEditingController();
  final TextEditingController precoProdutoController = TextEditingController();
  final TextEditingController nomeEventoExternoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarServico();
  }

  Future<void> _carregarServico() async {
    final doc = await FirebaseFirestore.instance
        .collection('servicosPrestados')
        .doc(widget.servicoId)
        .get();

    if (!doc.exists) {
      // Serviço não encontrado, volta
      if (mounted) Navigator.pop(context);
      return;
    }

    final data = doc.data()!;

    setState(() {
      categoria = data['categoria'] ?? '';
      produtos = List<Map<String, dynamic>>.from(data['produtos'] ?? []);
      valorTaxa = (data['valorTaxa'] ?? 0).toDouble();
      valorVendas = (data['valorVendas'] ?? 0).toDouble();
      despesas = (data['despesas'] ?? 0).toDouble();
      lucroEstim = (data['lucroEstim'] ?? 0).toDouble();

      eventoIdSelecionado = data['eventoId'];
      vincularEventoInterno = eventoIdSelecionado != null;
      nomeEventoExternoController.text = data['nomeEvento'] ?? '';

      _loading = false;
    });
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) return;

    final dadosAtualizados = {
      'categoria': categoria,
      'produtos': produtos,
      'valorTaxa': valorTaxa,
      'valorVendas': valorVendas,
      'despesas': despesas,
      'lucroEstim': lucroEstim,
      'eventoId': vincularEventoInterno ? eventoIdSelecionado : null,
      'nomeEvento': vincularEventoInterno ? null : nomeEventoExternoController.text.trim(),
      'data': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('servicosPrestados')
        .doc(widget.servicoId)
        .update(dadosAtualizados);

    if (mounted) Navigator.pop(context);
  }

  Widget _buildDoubleField(String label, double value, void Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Campo obrigatório';
          if (double.tryParse(val) == null) return 'Digite um número válido';
          return null;
        },
        onChanged: (val) => onChanged(double.tryParse(val) ?? 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Categoria do Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: categoria.isNotEmpty ? categoria : null,
                decoration: const InputDecoration(labelText: 'Categoria do serviço'),
                items: categoriasDeServico.map((c) {
                  return DropdownMenuItem(
                    value: c.toLowerCase(),
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) => setState(() => categoria = val ?? ''),
                validator: (val) => (val == null || val.isEmpty) ? 'Escolha uma categoria' : null,
              ),

              const SizedBox(height: 16),

              const Text('Produtos', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nomeProdutoController,
                      decoration: const InputDecoration(hintText: 'Nome'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: precoProdutoController,
                      decoration: const InputDecoration(hintText: 'Preço'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final nome = nomeProdutoController.text.trim();
                      final preco = double.tryParse(precoProdutoController.text.trim()) ?? 0;
                      if (nome.isNotEmpty && preco > 0) {
                        setState(() {
                          produtos.add({'nome': nome, 'preco': preco});
                          nomeProdutoController.clear();
                          precoProdutoController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: produtos
                    .map(
                      (p) => Chip(
                        label: Text('${p['nome']} (R\$${p['preco']})'),
                        onDeleted: () => setState(() => produtos.remove(p)),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
              const Text('Valores Financeiros', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDoubleField('Taxa paga ao evento (R\$)', valorTaxa, (v) => valorTaxa = v),
              _buildDoubleField('Valor total de vendas (R\$)', valorVendas, (v) => valorVendas = v),
              _buildDoubleField('Despesas (R\$)', despesas, (v) => despesas = v),
              _buildDoubleField('Lucro estimado (R\$)', lucroEstim, (v) => lucroEstim = v),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Vincular a evento interno?'),
                value: vincularEventoInterno,
                onChanged: (val) => setState(() {
                  vincularEventoInterno = val;
                  if (!val) {
                    eventoIdSelecionado = null;
                    eventoNomeSelecionado = null;
                  }
                }),
              ),

              if (vincularEventoInterno)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('eventos')
                      .where('tipoEvento', isEqualTo: 'interno')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();

                    final eventos = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: eventoIdSelecionado,
                      items: eventos.map((doc) {
                        final dados = doc.data()! as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(dados['titulo'] ?? 'Sem título'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          eventoIdSelecionado = val;
                          final evento = eventos.firstWhere((e) => e.id == val);
                          eventoNomeSelecionado = (evento.data()! as Map)['titulo'];
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Selecionar evento'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Selecione um evento' : null,
                    );
                  },
                )
              else
                TextFormField(
                  controller: nomeEventoExternoController,
                  decoration: const InputDecoration(labelText: 'Nome do evento externo'),
                  validator: (val) {
                    if (!vincularEventoInterno && (val == null || val.trim().isEmpty)) {
                      return 'Informe o nome do evento externo';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarEdicao,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
