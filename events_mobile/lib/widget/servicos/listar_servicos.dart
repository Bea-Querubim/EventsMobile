import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../pages/forms/servicos/criar_servicos.dart';
import '../../../core/theme/font_style.dart';
import '../../../core/theme/color_style.dart';
import 'editar_servicos.dart';

class MeusServicosList extends StatelessWidget {
  final String emailPrestador;

  const MeusServicosList({super.key, required this.emailPrestador});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('servicosPrestados')
                .where('usuarioId', isEqualTo: emailPrestador)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final servicos = snapshot.data!.docs;

          if (servicos.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final doc = servicos[index];
              final servico = doc.data()! as Map<String, dynamic>;

              final isInterno = servico['eventoId'] != null;
              final eventoId = servico['eventoId'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    isInterno
                        ? FirebaseFirestore.instance
                            .collection('eventos')
                            .doc(eventoId)
                            .get()
                        : Future.value(
                          FirebaseFirestore.instance
                              .doc('eventos/dummy')
                              .snapshots()
                              .first,
                        ),

                builder: (context, eventoSnapshot) {
                  String nome = 'Sem nome';
                  if (isInterno) {
                    if (eventoSnapshot.hasData && eventoSnapshot.data!.exists) {
                      final eventoData =
                          eventoSnapshot.data!.data() as Map<String, dynamic>;
                      nome = eventoData['titulo'] ?? 'Evento interno';
                    } else {
                      nome = 'Evento interno';
                    }
                  } else {
                    nome = servico['nomeEvento'] ?? 'Sem nome';
                  }

                  final descricao = servico['descricao'] ?? 'Sem descrição';
                  final categoria =
                      servico['categoria'] ?? 'Categoria não definida';
                  final preco =
                      servico['valorVendas'] != null
                          ? 'R\$ ${servico['valorVendas'].toString()}'
                          : 'Preço não informado';
                  final status = servico['ativo'] == true ? 'Ativo' : 'Inativo';
                  final origem =
                      isInterno ? 'Evento interno' : 'Evento externo';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: AppColors.brand20,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título e status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$nome ($origem)',
                                  style: AppTextStyles.heading.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      status == 'Ativo'
                                          ? Colors.green[300]
                                          : Colors.red[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                constraints: const BoxConstraints(maxWidth: 80),
                                child: Text(
                                  status,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(descricao, style: AppTextStyles.body),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 20,
                                color: AppColors.grey60,
                              ),
                              const SizedBox(width: 6),
                              Text(categoria, style: AppTextStyles.caption),
                              const SizedBox(width: 20),
                              Icon(
                                Icons.attach_money,
                                size: 20,
                                color: AppColors.grey60,
                              ),
                              const SizedBox(width: 6),
                              Text(preco, style: AppTextStyles.caption),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  'Editar',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              EditarServico(servicoId: doc.id),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Excluir serviço'),
                                          content: const Text(
                                            'Deseja excluir este serviço?',
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
                                        .collection('servicosPrestados')
                                        .doc(doc.id)
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
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarServicos()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
