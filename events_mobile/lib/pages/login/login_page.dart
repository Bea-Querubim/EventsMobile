import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_mobile/services/auth_service.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        error = '';
      });

      try {
        final user = await _authService.signIn(email, password);

        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get();

          // Redireciona para o template base e depois manda de acordo com o tipo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BaseHomePage()),
          );
        }
      } catch (e) {
        setState(() {
          error = 'Falha no login. Verifique seus dados.';
        });
      } finally {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) => val != null && val.contains('@') ? null : 'Informe um email válido',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) => val != null && val.length >= 6 ? null : 'Senha deve ter ao menos 6 caracteres',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Entrar'),
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
