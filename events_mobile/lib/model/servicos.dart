import 'package:cloud_firestore/cloud_firestore.dart';

class ServicoPrestado {
  final String? id;
  final String usuarioId; // email do prestador
  final String? eventoId; // null se for evento externo
  final String? nomeEvento; // usado apenas se evento for externo
  final String categoria; // comida, bebida, etc
  final List<Map<String, dynamic>> produtos; // [{nome, preco}]
  final DateTime? data; // data do serviço
  final double valorTaxa;
  final double valorVendas;
  final double despesas;
  final double lucroEstim;

  ServicoPrestado({
    this.id,
    required this.usuarioId,
    this.eventoId,
    this.nomeEvento,
    required this.categoria,
    required this.produtos,
    this.data,
    this.valorTaxa = 0.0,
    this.valorVendas = 0.0,
    this.despesas = 0.0,
    this.lucroEstim = 0.0,
  });

  factory ServicoPrestado.fromMap(Map<String, dynamic> map, String id) {
    return ServicoPrestado(
      id: id,
      usuarioId: map['usuarioId'],
      eventoId: map['eventoId'],
      nomeEvento: map['nomeEvento'],
      categoria: map['categoria'],
      produtos: List<Map<String, dynamic>>.from(map['produtos'] ?? []),
      data: map['data'] != null ? (map['data'] as Timestamp).toDate() : null,
      valorTaxa: (map['valorTaxa'] ?? 0).toDouble(),
      valorVendas: (map['valorVendas'] ?? 0).toDouble(),
      despesas: (map['despesas'] ?? 0).toDouble(),
      lucroEstim: (map['lucroEstim'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'eventoId': eventoId,
      'nomeEvento': nomeEvento,
      'categoria': categoria,
      'produtos': produtos,
      'data': data != null ? Timestamp.fromDate(data!) : null,
      'valorTaxa': valorTaxa,
      'valorVendas': valorVendas,
      'despesas': despesas,
      'lucroEstim': lucroEstim,
    };
  }
}
