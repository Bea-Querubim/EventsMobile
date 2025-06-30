import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class RelatorioServicos extends StatefulWidget {
  const RelatorioServicos({super.key});

  @override
  State<RelatorioServicos> createState() => _RelatorioServicosState();
}

class _RelatorioServicosState extends State<RelatorioServicos> {
  Map<String, Map<String, double>> resumoMensal = {};
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('servicosPrestados')
            .where('usuarioId', isEqualTo: user.email)
            .get();

    final formatter = DateFormat('MM/yyyy');

    for (final doc in snapshot.docs) {
      final dados = doc.data();
      final data = (dados['data'] as Timestamp?)?.toDate();
      if (data == null) continue;

      final mesAno = formatter.format(data);
      final vendas = (dados['valorVendas'] ?? 0).toDouble();
      final despesas = (dados['despesas'] ?? 0).toDouble();
      final lucro = (dados['lucroEstim'] ?? 0).toDouble();

      resumoMensal.putIfAbsent(
        mesAno,
        () => {'vendas': 0.0, 'despesas': 0.0, 'lucro': 0.0},
      );

      resumoMensal[mesAno]!['vendas'] =
          (resumoMensal[mesAno]!['vendas'] ?? 0) + vendas;
      resumoMensal[mesAno]!['despesas'] =
          (resumoMensal[mesAno]!['despesas'] ?? 0) + despesas;
      resumoMensal[mesAno]!['lucro'] =
          (resumoMensal[mesAno]!['lucro'] ?? 0) + lucro;
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    final mesesOrdenados =
        resumoMensal.keys.toList()..sort(
          (a, b) => DateFormat(
            'MM/yyyy',
          ).parse(a).compareTo(DateFormat('MM/yyyy').parse(b)),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Financeiro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
          carregando
              ? const Center(child: CircularProgressIndicator())
              : resumoMensal.isEmpty
              ? const Center(child: Text('Nenhum dado disponível'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Lucro Estimado por Mês',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 500,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      'R\$ ${value.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 &&
                                      index < mesesOrdenados.length) {
                                    return Text(
                                      mesesOrdenados[index].substring(0, 5),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(mesesOrdenados.length, (
                            index,
                          ) {
                            final mes = mesesOrdenados[index];
                            final lucro = resumoMensal[mes]!['lucro']!;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: lucro,
                                  color: Colors.teal,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: mesesOrdenados.length,
                        itemBuilder: (context, index) {
                          final mes = mesesOrdenados[index];
                          final d = resumoMensal[mes]!;

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mês: $mes',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Vendas:',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${d['vendas']!.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Despesas:',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${d['despesas']!.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lucro Estimado:',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${d['lucro']!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
