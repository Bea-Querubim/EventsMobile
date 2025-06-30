import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_mobile/pages/forms/eventos/criar_evento.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/font_style.dart';
import '../../../core/theme/color_style.dart';

class MeusEventosList extends StatefulWidget {
  final String emailOrganizador;

  const MeusEventosList({super.key, required this.emailOrganizador});

  @override
  State<MeusEventosList> createState() => _MeusEventosListState();
}

class _MeusEventosListState extends State<MeusEventosList> {
  String _filtroTipo = 'todos';
  bool _ordemDecrescente = true;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Eventos',
          style: AppTextStyles.heading.copyWith(color: AppColors.textLight),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Filtro por tipo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroTipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Evento',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'interno',
                        child: Text('Interno'),
                      ),
                      DropdownMenuItem(
                        value: 'externo',
                        child: Text('Externo'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _filtroTipo = value!),
                  ),
                ),
                const SizedBox(width: 12),
                // Ordem por data
                IconButton(
                  tooltip: _ordemDecrescente ? 'Mais recente' : 'Mais antigo',
                  icon: Icon(
                    _ordemDecrescente
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: AppColors.grey70,
                  ),
                  onPressed:
                      () => setState(
                        () => _ordemDecrescente = !_ordemDecrescente,
                      ),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('eventos')
                      .where(
                        'idOrganizador',
                        isEqualTo: widget.emailOrganizador,
                      )
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                List<Map<String, dynamic>> eventos =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {
                        'id': doc.id,
                        'titulo': data['titulo'],
                        'descricao': data['descricao'],
                        'dataInicio': data['dataInicio'],
                        'tipoEvento': data['tipoEvento'],
                        'eventoCompleto': data, // se quiser usar tudo depois
                      };
                    }).toList();

                // Filtro por tipo
                if (_filtroTipo != 'todos') {
                  eventos =
                      eventos
                          .where((e) => e['tipoEvento'] == _filtroTipo)
                          .toList();
                }

                // Ordenação por data
                eventos.sort((a, b) {
                  final dataA =
                      DateTime.tryParse(a['dataInicio'] ?? '') ??
                      DateTime(1900);
                  final dataB =
                      DateTime.tryParse(b['dataInicio'] ?? '') ??
                      DateTime(1900);

                  return _ordemDecrescente
                      ? dataB.compareTo(dataA)
                      : dataA.compareTo(dataB);
                });

                if (eventos.isEmpty) {
                  return const Center(child: Text('Nenhum evento encontrado.'));
                }

                return ListView.builder(
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final evento = eventos[index];
                    final id = eventos[index]['id'];

                    final dataInicio =
                        evento['dataInicio'] != null
                            ? DateTime.tryParse(evento['dataInicio'])?.toLocal()
                            : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                              evento['titulo'] ?? 'Sem título',
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              evento['descricao'] ?? '',
                              style: AppTextStyles.body,
                            ),
                            if (dataInicio != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Data: ${dataInicio.toString().split(' ')[0]}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CriarEvento(eventoId: id),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Excluir',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text('Excluir evento'),
                                            content: const Text(
                                              'Tem certeza que deseja excluir este evento?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Excluir'),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('eventos')
                                          .doc(id)
                                          .delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarEvento()),
          );
        },
      ),
    );
  }
}
