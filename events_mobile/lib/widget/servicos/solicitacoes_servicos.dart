import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SolicitacoesServicos extends StatefulWidget {
  final String emailOrganizador;

  const SolicitacoesServicos({super.key, required this.emailOrganizador});

  @override
  State<SolicitacoesServicos> createState() => _SolicitacoesServicosState();
}

class _SolicitacoesServicosState extends State<SolicitacoesServicos> {
  late Future<List<Map<String, dynamic>>> _futureSolicitacoes;

  @override
  void initState() {
    super.initState();
    _loadSolicitacoes();
  }

  void _loadSolicitacoes() {
    _futureSolicitacoes = _buscarSolicitacoes();
  }

  Future<List<Map<String, dynamic>>> _buscarSolicitacoes() async {
    final eventosQuery = await FirebaseFirestore.instance
        .collection('eventos')
        .where('idOrganizador', isEqualTo: widget.emailOrganizador)
        .get();

    final eventoIds = eventosQuery.docs.map((e) => e.id).toList();

    final servicosQuery = await FirebaseFirestore.instance
        .collection('servicosPrestados')
        .where('eventoId', whereIn: eventoIds.isEmpty ? ['---'] : eventoIds)
        .get();

    return servicosQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _aprovarSolicitacao(Map<String, dynamic> solicitacao) async {
    final eventoId = solicitacao['eventoId'];
    final categoria = solicitacao['categoria'];
    final usuarioId = solicitacao['usuarioId'];

    final eventoRef = FirebaseFirestore.instance.collection('eventos').doc(eventoId);

    final eventoDoc = await eventoRef.get();
    if (!eventoDoc.exists) return;

    final eventoData = eventoDoc.data()!;
    final List<dynamic> servicos = List.from(eventoData['servicos'] ?? []);

    if (!servicos.any((s) => s['nome'] == categoria)) {
      servicos.add({
        'id': usuarioId,
        'nome': categoria,
      });

      await eventoRef.update({'servicos': servicos});
    }

    await FirebaseFirestore.instance
        .collection('servicosPrestados')
        .doc(solicitacao['id'])
        .update({'aprovado': true});
  }

  Future<void> _recusarSolicitacao(String idSolicitacao) async {
    await FirebaseFirestore.instance.collection('servicosPrestados').doc(idSolicitacao).delete();
  }

  void _atualizarLista() {
    setState(() {
      _loadSolicitacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações de Serviços')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureSolicitacoes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final solicitacoes = snapshot.data!;
          if (solicitacoes.isEmpty) return const Center(child: Text('Nenhuma solicitação encontrada.'));

          return ListView.builder(
            itemCount: solicitacoes.length,
            itemBuilder: (context, index) {
              final s = solicitacoes[index];
              final aprovado = s['aprovado'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(s['nomeEvento']),
                  subtitle: Text('Serviço: ${s['categoria']} • Solicitado por: ${s['usuarioId']}'),
                  trailing: aprovado == null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Aprovar',
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await _aprovarSolicitacao(s);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Serviço aprovado e adicionado ao evento!')),
                                );
                                _atualizarLista();
                              },
                            ),
                            IconButton(
                              tooltip: 'Recusar',
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await _recusarSolicitacao(s['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Solicitação recusada.')),
                                );
                                _atualizarLista();
                              },
                            ),
                          ],
                        )
                      : aprovado == true
                          ? const Text(
                              'Aprovado',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            )
                          : const Text(
                              'Recusado',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
