import 'package:flutter/material.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';
import '../../model/user.dart';

class FormStep4 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String location;

  const FormStep4({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.location,
  });

  @override
  State<FormStep4> createState() => _FormStep4State();
}

class _FormStep4State extends State<FormStep4> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  void _finishForm() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        nome: '${widget.firstName} ${widget.lastName}',
        email: widget.email,
        senha: _passwordController.text,
        locale: widget.location
      );

      print('✅ Usuário criado com sucesso:');
      print('Nome: ${user.name}');
      print('Email: ${user.email}');
      print('Senha: ${user.password}');
      print('Localização: ${user.locale}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: isDark ? AppColors.grey40 : AppColors.grey10,
              color: AppColors.brand70,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 24),
            Text('Choose a password', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text('Make sure it is secure and easy to remember', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: isDark ? AppColors.grey80 : AppColors.grey10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                   // borderSide: BorderSide(color: AppColors.grey50),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _finishForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand70,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'Finish',
            style: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
