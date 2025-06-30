import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/font_style.dart';
import '../../../core/theme/color_style.dart';

class ListarEventosPrestador extends StatefulWidget {
  final String usuarioEmail;

  const ListarEventosPrestador({super.key, required this.usuarioEmail});

  @override
  State<ListarEventosPrestador> createState() => _ListarEventosPrestadorState();
}

class _ListarEventosPrestadorState extends State<ListarEventosPrestador> {
  late final FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Future<List<Map<String, dynamic>>> _buscarEventosAprovados() async {
    // 1. Busca todos os serviços aprovados para o usuário
    final servicosSnapshot = await _firestore
        .collection('servicosPrestados')
        .where('usuarioId', isEqualTo: widget.usuarioEmail)
        .where('aprovado', isEqualTo: true)
        .get();

    // Se não tiver serviços aprovados, retorna vazio
    if (servicosSnapshot.docs.isEmpty) return [];

    // 2. Para cada serviço, buscar o evento vinculado
    List<Map<String, dynamic>> eventosAprovados = [];

    for (final docServico in servicosSnapshot.docs) {
      final servicoData = docServico.data();
      final eventoId = servicoData['eventoId'];

      // Busca o evento
      final eventoDoc = await _firestore.collection('eventos').doc(eventoId).get();
      if (!eventoDoc.exists) continue;

      final eventoData = eventoDoc.data()!;
      eventosAprovados.add({
        'servicoPrestadoId': docServico.id,
        'eventoId': eventoId,
        'titulo': eventoData['titulo'] ?? 'Sem título',
        'descricao': eventoData['descricao'] ?? '',
        'dataInicio': eventoData['dataInicio'] ?? '',
        'tipoEvento': eventoData['tipoEvento'] ?? '',
        'categoriaServico': servicoData['categoria'] ?? 'Serviço',
      });
    }

    return eventosAprovados;
  }

  Future<void> _sairDoEvento(String servicoPrestadoId) async {
    // Aqui pode ser:
    // - Deletar o documento da coleção servicosPrestados
    // - Ou atualizar para 'aprovado: false'
    await _firestore.collection('servicosPrestados').doc(servicoPrestadoId).delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você saiu do evento com sucesso.')),
      );
      setState(() {}); // Atualiza a lista
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Eventos Aprovados'),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _buscarEventosAprovados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum evento aprovado.'));
          }

          final eventos = snapshot.data!;

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];

              final dataInicio = DateTime.tryParse(evento['dataInicio'])?.toLocal();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                color: AppColors.brand20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento['titulo'],
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evento['descricao'],
                        style: AppTextStyles.body,
                      ),
                      if (dataInicio != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Data: ${dataInicio.toString().split(' ')[0]}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Serviço aprovado: ${evento['categoriaServico']}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('Sair do Evento'),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirmação'),
                                  content: const Text('Deseja realmente sair deste evento?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _sairDoEvento(evento['servicoPrestadoId']);
                              }
                            },
                          ),
                        ],
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
