import 'package:flutter/material.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';
import 'form_step3.dart';

class FormStep2 extends StatefulWidget {
  final String firstName;
  final String lastName;

  const FormStep2({super.key, required this.firstName, required this.lastName});

  @override
  State<FormStep2> createState() => _FormStep2State();
}

class _FormStep2State extends State<FormStep2> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => FormStep3(
                firstName: widget.firstName,
                lastName: widget.lastName,
                email: _emailController.text,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 0.50,
              backgroundColor: isDark ? AppColors.brand80 : AppColors.grey20,
              color: AppColors.brand70,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "What's your emai address?",
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email Adress',
                      filled: true,
                      fillColor: isDark ? AppColors.grey80 : AppColors.grey10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.grey80 : AppColors.grey20,
                        ),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter with your email' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand70,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text('Continue', style: AppTextStyles.button),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
