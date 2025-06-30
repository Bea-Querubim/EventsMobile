enum TipoEvento {
  interno,
  externo,
}

class Evento {
  final String idOrganizador;
  final String titulo;
  final String? descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String horaInicio;
  final String horaFim;
  final String? local;
  final double? latitude;
  final double? longitude;
  final List<Map<String, String>> servicos;
  final List<String>? participantes;
  final TipoEvento tipoEvento;

  Evento({
    required this.idOrganizador,
    required this.titulo,
    this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.horaInicio,
    required this.horaFim,
    required this.local,
    this.latitude,
    this.longitude,
    required this.servicos,
    this.participantes,
    required this.tipoEvento,
  });

  Map<String, dynamic> toJson() {
    return {
      "idOrganizador": idOrganizador,
      "titulo": titulo,
      "descricao": descricao,
      "dataInicio": dataInicio.toIso8601String(),
      "dataFim": dataFim.toIso8601String(),
      "horaInicio": horaInicio,
      "horaFim": horaFim,
      "local": local,
      "latitude": latitude,
      "longitude": longitude,
      "servicos": servicos,
      "participantes": participantes ?? [],
      "tipoEvento": tipoEvento.name,
    };
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      idOrganizador: json['idOrganizador'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataInicio: DateTime.parse(json['dataInicio']),
      dataFim: DateTime.parse(json['dataFim']),
      horaInicio: json['horaInicio'],
      horaFim: json['horaFim'],
      local: json['local'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      servicos: List<Map<String, String>>.from(
        (json['servicos'] as List).map((e) => Map<String, String>.from(e)),
      ),
      participantes: json['participantes'] != null
          ? List<String>.from(json['participantes'])
          : [],
      tipoEvento: TipoEvento.values.firstWhere(
        (e) => e.name == json['tipoEvento'],
        orElse: () => TipoEvento.interno,
      ),
    );
  }
}