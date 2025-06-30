import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_mobile/services/auth_service.dart';
import 'package:events_mobile/model/user.dart';
import '../home/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool loading = false;

  String nome = '';
  String email = '';
  String senha = '';
  int telefone = 0;
  TipoUsuario tipoUsuario = TipoUsuario.organizador;
  String error = '';

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        error = '';
      });

      try {
        // 1. Criar conta no Firebase Auth
        final user = await _authService.signUp(email, senha);

        if (user != null) {
          // 2. Salvar perfil no Firestore
          final profile = UserProfile(
            nome: nome,
            email: email,
            senha: senha,
            tipo: tipoUsuario,
            telefone: telefone,
          );

          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .set(profile.toJson());

          setState(() => loading = false);

          // Redireciona para o template base e depois manda de acordo com o tipo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BaseHomePage()),
          );
        }
      } catch (e) {
        setState(() {
          error = 'Erro ao cadastrar: $e';
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (val) => nome = val,
                validator: (val) => val!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator:
                    (val) => val!.contains('@') ? null : 'Email inválido',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (val) => senha = val,
                validator: (val) => val!.length < 6 ? 'Senha fraca' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => telefone = int.tryParse(val) ?? 0,
                validator:
                    (val) =>
                        (int.tryParse(val ?? '') ?? 0) > 0
                            ? null
                            : 'Informe um telefone válido',
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<TipoUsuario>(
                value: tipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de usuário'),
                items: const [
                  DropdownMenuItem(
                    value: TipoUsuario.organizador,
                    child: Text('Organizador'),
                  ),
                  DropdownMenuItem(
                    value: TipoUsuario.prestador,
                    child: Text('Prestador de serviços'),
                  ),
                ],
                onChanged:
                    (val) => setState(
                      () => tipoUsuario = val ?? TipoUsuario.organizador,
                    ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _signup,
                child: const Text('Cadastrar'),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
