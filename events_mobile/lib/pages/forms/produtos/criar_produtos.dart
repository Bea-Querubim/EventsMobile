import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CriarProduto extends StatefulWidget {
  const CriarProduto({super.key});

  @override
  State<CriarProduto> createState() => _CriarProdutoState();
}

class _CriarProdutoState extends State<CriarProduto> {
  final _formKey = GlobalKey<FormState>();
  final nomeProdutoController = TextEditingController();
  final precoProdutoController = TextEditingController();

  String? servicoIdSelecionado;
  List<Map<String, dynamic>> produtos = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Produtos ao Serviço')),
      body: user == null
          ? const Center(child: Text("Usuário não autenticado"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text('Escolha um Serviço'),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('servicosPrestados')
                          .where('usuarioId', isEqualTo: user.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        final servicos = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: servicoIdSelecionado,
                          decoration: const InputDecoration(labelText: 'Serviço'),
                          items: servicos.map((doc) {
                            final dados = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text('${dados['categoria']} - ${dados['nomeEvento'] ?? 'Evento interno'}'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => servicoIdSelecionado = val),
                          validator: (val) => val == null ? 'Escolha um serviço' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Novo Produto'),
                    TextFormField(
                      controller: nomeProdutoController,
                      decoration: const InputDecoration(labelText: 'Nome do produto'),
                    ),
                    TextFormField(
                      controller: precoProdutoController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                    ),
                    ElevatedButton(
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
                      child: const Text('Adicionar Produto'),
                    ),
                    Wrap(
                      spacing: 8,
                      children: produtos.map((p) => Chip(
                        label: Text('${p['nome']} (R\$${p['preco']})'),
                        onDeleted: () => setState(() => produtos.remove(p)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _salvarProdutos,
                      child: const Text('Salvar Produtos'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _salvarProdutos() async {
    if (!_formKey.currentState!.validate() || servicoIdSelecionado == null) return;

    final ref = FirebaseFirestore.instance.collection('servicosPrestados').doc(servicoIdSelecionado);

    final doc = await ref.get();
    final dados = doc.data() as Map<String, dynamic>;
    final produtosExistentes = List<Map<String, dynamic>>.from(dados['produtos'] ?? []);

    await ref.update({
      'produtos': [...produtosExistentes, ...produtos],
    });

    if (mounted) Navigator.pop(context);
  }
}
