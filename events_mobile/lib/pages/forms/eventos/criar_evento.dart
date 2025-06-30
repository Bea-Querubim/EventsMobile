import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/categoria_servicos.dart';
import '../../../model/events.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CriarEvento extends StatefulWidget {
  final String? eventoId;

  const CriarEvento({super.key, this.eventoId});

  @override
  State<CriarEvento> createState() => _CriarEventoState();
}

class _CriarEventoState extends State<CriarEvento> {
  final _formKey = GlobalKey<FormState>();

  String titulo = '';
  String descricao = '';
  DateTime? dataInicio;
  DateTime? dataFim;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFim;
  String local = '';
  List<Map<String, String>> servicosSelecionados = [];
  List<String> participantes = [];
  double? latitude;
  double? longitude;
  TipoEvento tipoEventoSelecionado = TipoEvento.interno;

  final TextEditingController participanteController = TextEditingController();
  late final List<Map<String, String>> servicosDisponiveis;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Carrega as categorias centralizadas convertidas para Map<String,String>
    servicosDisponiveis =
        categoriasDeServico
            .asMap()
            .entries
            .map((e) => {'id': e.key.toString(), 'nome': e.value})
            .toList();

    if (widget.eventoId != null) _carregarEvento();
  }

  Future<void> _carregarEvento() async {
    setState(() => loading = true);
    final doc =
        await FirebaseFirestore.instance
            .collection('eventos')
            .doc(widget.eventoId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        titulo = data['titulo'] ?? '';
        descricao = data['descricao'] ?? '';
        local = data['local'] ?? '';
        dataInicio =
            data['dataInicio'] != null
                ? DateTime.parse(data['dataInicio'])
                : null;
        dataFim =
            data['dataFim'] != null ? DateTime.parse(data['dataFim']) : null;
        horaInicio =
            data['horaInicio'] != null ? _parseTime(data['horaInicio']) : null;
        horaFim = data['horaFim'] != null ? _parseTime(data['horaFim']) : null;
        latitude = data['latitude'];
        longitude = data['longitude'];
        servicosSelecionados = List<Map<String, String>>.from(
          (data['servicos'] ?? []).map((s) => Map<String, String>.from(s)),
        );
        participantes = List<String>.from(data['participantes'] ?? []);
        if (data['tipoEvento'] != null) {
          tipoEventoSelecionado = TipoEvento.values.firstWhere(
            (e) => e.name == data['tipoEvento'],
            orElse: () => TipoEvento.interno,
          );
        }

        loading = false;
      });
    }
  }

  Future<void> _obterLocalizacao() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está ativado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço de localização desativado')),
      );
      await _converterCoordenadasParaEndereco();
      return;
    }

    // Verifica permissões
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão de localização permanentemente negada'),
        ),
      );
      return;
    }

    // Obtém localização
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = pos.latitude;
      longitude = pos.longitude;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Localização obtida com sucesso!')));
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _converterCoordenadasParaEndereco() async {
    if (latitude == null || longitude == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          local =
              '${place.street}, ${place.subLocality}, '
              '${place.locality} - ${place.administrativeArea}, '
              '${place.postalCode}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço atualizado com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao obter endereço: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventoId != null ? 'Editar Evento' : 'Novo Evento'),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildLabel('Título'),
                      TextFormField(
                        initialValue: titulo,
                        onChanged: (val) => titulo = val,
                        validator:
                            (val) => val!.isEmpty ? 'Informe o título' : null,
                      ),
                      _buildLabel('Descrição'),
                      TextFormField(
                        initialValue: descricao,
                        onChanged: (val) => descricao = val,
                        maxLines: 3,
                      ),
                      _buildLabel('Data de Início'),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dataInicio ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null)
                            setState(() => dataInicio = picked);
                        },
                        child: Text(
                          dataInicio != null
                              ? '${dataInicio!.day}/${dataInicio!.month}/${dataInicio!.year}'
                              : 'Selecionar',
                        ),
                      ),
                      _buildLabel('Data final'),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dataFim ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => dataFim = picked);
                        },
                        child: Text(
                          dataFim != null
                              ? '${dataFim!.day}/${dataFim!.month}/${dataFim!.year}'
                              : 'Selecionar',
                        ),
                      ),
                      _buildLabel('Hora de Início'),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: horaInicio ?? TimeOfDay.now(),
                          );
                          if (picked != null)
                            setState(() => horaInicio = picked);
                        },
                        child: Text(
                          horaInicio != null
                              ? horaInicio!.format(context)
                              : 'Selecionar',
                        ),
                      ),
                      _buildLabel('Hora Final'),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: horaFim ?? TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => horaFim = picked);
                        },
                        child: Text(
                          horaFim != null
                              ? horaFim!.format(context)
                              : 'Selecionar',
                        ),
                      ),
                      _buildLabel('Local'),
                      TextFormField(
                        initialValue: local,
                        onChanged: (val) => local = val,
                      ),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Usar minha localização'),
                        onPressed: _obterLocalizacao,
                      ),
                      if (latitude != null && longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Lat: $latitude\nLong: $longitude'),
                        ),

                      _buildLabel('Tipo do Evento'),
                      DropdownButtonFormField<TipoEvento>(
                        value: tipoEventoSelecionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items:
                            TipoEvento.values.map((tipo) {
                              return DropdownMenuItem<TipoEvento>(
                                value: tipo,
                                child: Text(
                                  tipo.name[0].toUpperCase() +
                                      tipo.name.substring(1),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              tipoEventoSelecionado = value;
                            });
                          }
                        },
                      ),
                      _buildLabel('Serviços no Evento'),
                      Wrap(
                        spacing: 8,
                        children:
                            servicosDisponiveis.map((servico) {
                              final isSelected = servicosSelecionados.any(
                                (s) => s['nome'] == servico['nome'],
                              );
                              return FilterChip(
                                label: Text(servico['nome']!),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      servicosSelecionados.add(servico);
                                    } else {
                                      servicosSelecionados.removeWhere(
                                        (s) => s['nome'] == servico['nome'],
                                      );
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      _buildLabel('Participantes (email)'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: participanteController,
                              decoration: const InputDecoration(
                                hintText: 'email@exemplo.com',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final email = participanteController.text.trim();
                              if (email.isNotEmpty) {
                                setState(() {
                                  participantes.add(email);
                                  participanteController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children:
                            participantes
                                .map(
                                  (p) => Chip(
                                    label: Text(p),
                                    onDeleted:
                                        () => setState(
                                          () => participantes.remove(p),
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _salvarEvento,
                        child: Text(
                          widget.eventoId != null
                              ? 'Salvar Alterações'
                              : 'Criar Evento',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _salvarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final evento = {
      'idOrganizador': user?.email ?? '',
      'titulo': titulo,
      'descricao': descricao,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'horaInicio': horaInicio?.format(context),
      'horaFim': horaFim?.format(context),
      'local': local,
      'tipoEvento': tipoEventoSelecionado.name,
      'latitude': latitude,
      'longitude': longitude,
      'servicos': servicosSelecionados,
      'participantes': participantes,
      'criadoEm': Timestamp.now(),
    };

    final eventosRef = FirebaseFirestore.instance.collection('eventos');

    if (widget.eventoId != null) {
      await eventosRef.doc(widget.eventoId).update(evento);
    } else {
      await eventosRef.add(evento);
    }

    setState(() => loading = false);
    if (mounted) Navigator.pop(context);
  }
}
