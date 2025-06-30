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

    final snapshot = await FirebaseFirestore.instance
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

      resumoMensal[mesAno] ??= {
        'vendas': 0,
        'despesas': 0,
        'lucro': 0,
      };

      resumoMensal[mesAno]!['vendas'] = resumoMensal[mesAno]!['vendas']! + vendas;
      resumoMensal[mesAno]!['despesas'] = resumoMensal[mesAno]!['despesas']! + despesas;
      resumoMensal[mesAno]!['lucro'] = resumoMensal[mesAno]!['lucro']! + lucro;
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mesesOrdenados = resumoMensal.keys.toList()
      ..sort((a, b) => DateFormat('MM/yyyy').parse(a).compareTo(DateFormat('MM/yyyy').parse(b)));

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório Financeiro')),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : resumoMensal.isEmpty
              ? const Center(child: Text('Nenhum dado disponível'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Lucro Estimado por Mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 100,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < mesesOrdenados.length) {
                                      return Text(mesesOrdenados[index].substring(0, 5)); // 06/2025 → 06/20
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(mesesOrdenados.length, (index) {
                              final mes = mesesOrdenados[index];
                              final lucro = resumoMensal[mes]!['lucro']!;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(toY: lucro, color: Colors.green, width: 20),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: mesesOrdenados.map((mes) {
                            final d = resumoMensal[mes]!;
                            return ListTile(
                              title: Text('Mês: $mes'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vendas: R\$ ${d['vendas']!.toStringAsFixed(2)}'),
                                  Text('Despesas: R\$ ${d['despesas']!.toStringAsFixed(2)}'),
                                  Text('Lucro Estimado: R\$ ${d['lucro']!.toStringAsFixed(2)}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
