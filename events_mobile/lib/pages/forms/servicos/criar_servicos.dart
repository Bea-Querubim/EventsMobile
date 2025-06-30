import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/categoria_servicos.dart';

class CriarServicos extends StatefulWidget {
  const CriarServicos({super.key});

  @override
  State<CriarServicos> createState() => _CriarServicosState();
}

class _CriarServicosState extends State<CriarServicos> {
  final _formKey = GlobalKey<FormState>();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Serviço Prestado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Categoria do Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                  value: categoria.isNotEmpty ? categoria : null,
                  decoration: const InputDecoration(
                    labelText: 'Categoria do serviço',
                  ),
                  items:
                      categoriasDeServico.map((categoria) {
                        return DropdownMenuItem<String>(
                          value:
                              categoria
                                  .toLowerCase(), // salva como 'comida', 'bebida' etc.
                          child: Text(categoria),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categoria = value ?? '';
                    });
                  },
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Escolha uma categoria'
                              : null,
                ),

              const SizedBox(height: 16),
              const Text('Produtos', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: TextField(controller: nomeProdutoController, decoration: const InputDecoration(hintText: 'Nome'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: precoProdutoController, decoration: const InputDecoration(hintText: 'Preço'), keyboardType: TextInputType.number)),
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
                    .map((p) => Chip(
                          label: Text('${p['nome']} (R\$${p['preco']})'),
                          onDeleted: () => setState(() => produtos.remove(p)),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 16),
              const Text('Valores Financeiros', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDoubleField('Taxa paga ao evento (R\$)', (v) => valorTaxa = v),
              _buildDoubleField('Valor total de vendas (R\$)', (v) => valorVendas = v),
              _buildDoubleField('Despesas (R\$)', (v) => despesas = v),
              _buildDoubleField('Lucro estimado (R\$)', (v) => lucroEstim = v),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Vincular a evento interno?'),
                value: vincularEventoInterno,
                onChanged: (val) => setState(() {
                  vincularEventoInterno = val;
                  if (!val) eventoIdSelecionado = eventoNomeSelecionado = null;
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
                    );
                  },
                )
              else
                TextFormField(
                  controller: nomeEventoExternoController,
                  decoration: const InputDecoration(labelText: 'Nome do evento externo'),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarServico,
                child: const Text('Salvar Serviço'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleField(String label, void Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (val) => onChanged(double.tryParse(val) ?? 0),
      ),
    );
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final servico = {
      'usuarioId': user.email,
      'eventoId': vincularEventoInterno ? eventoIdSelecionado : null,
      'nomeEvento': vincularEventoInterno ? null : nomeEventoExternoController.text.trim(),
      'categoria': categoria,
      'produtos': produtos,
      'valorTaxa': valorTaxa,
      'valorVendas': valorVendas,
      'despesas': despesas,
      'lucroEstim': lucroEstim,
      'data': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('servicosPrestados').add(servico);

    if (mounted) Navigator.pop(context);
  }
}
