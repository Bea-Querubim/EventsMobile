import 'package:flutter/material.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';
import 'form_step4.dart';

class FormStep3 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const FormStep3({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  State<FormStep3> createState() => _FormStep3State();
}

class _FormStep3State extends State<FormStep3> {
  final _formKey = GlobalKey<FormState>();

  final _localizacaoController = TextEditingController();

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => FormStep4(
                firstName: widget.firstName,
                lastName: widget.lastName,
                email: widget.email,
                location: _localizacaoController.text,
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
              value: 0.75,
              backgroundColor: isDark ? AppColors.brand80 : AppColors.grey20,
              color: AppColors.brand70,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "What's your location?",
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
                    controller: _localizacaoController,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      filled: true,
                      fillColor: isDark ? AppColors.grey80 : AppColors.grey20,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.grey50 : AppColors.grey70,
                        ),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter with your location' : null,
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
