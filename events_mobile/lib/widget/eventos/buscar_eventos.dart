import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventosDisponiveisList extends StatelessWidget {
  const EventosDisponiveisList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Eventos Disponíveis')),
      body: user == null
          ? const Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('eventos')
                  .where('tipoEvento', isEqualTo: 'interno')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final eventos = snapshot.data!.docs;

                if (eventos.isEmpty) {
                  return const Center(child: Text('Nenhum evento disponível.'));
                }

                return ListView.builder(
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final doc = eventos[index];
                    final dados = doc.data()! as Map<String, dynamic>;
                    final servicos = List<Map<String, dynamic>>.from(dados['servicos'] ?? []);

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dados['titulo'] ?? 'Sem título',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(dados['dataInicio'] != null
                                ? 'Data: ${DateTime.parse(dados['dataInicio']).toLocal().toString().split(' ')[0]}'
                                : ''),
                            const SizedBox(height: 10),
                            const Text('Serviços disponíveis:'),
                            Wrap(
                              spacing: 8,
                              children: servicos.map((s) {
                                return ElevatedButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Confirmar solicitação'),
                                        content: Text('Você deseja prestar o serviço de "${s['nome']}" neste evento?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance.collection('servicosPrestados').add({
                                        'usuarioId': user.email,
                                        'eventoId': doc.id,
                                        'nomeEvento': dados['titulo'],
                                        'categoria': s['nome'].toString().toLowerCase(),
                                        'produtos': [],
                                        'valorTaxa': 0,
                                        'valorVendas': 0,
                                        'despesas': 0,
                                        'lucroEstim': 0,
                                        'data': Timestamp.now(),
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Solicitação enviada com sucesso')),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(s['nome']),
                                );
                              }).toList(),
                            )
                          ],
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
