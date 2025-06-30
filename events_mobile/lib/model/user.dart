enum TipoUsuario {
  organizador,
  prestador,
}

class UserProfile {
  final String nome;
  final String email;
  final String senha;
  final TipoUsuario tipo;
  final int telefone;

  UserProfile({
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    required this.telefone,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipo': tipo.name,
        'telefone': telefone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoUsuario.organizador,
      ),
      telefone: json['telefone'],
    );
  }
}
