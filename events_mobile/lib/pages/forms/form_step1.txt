import 'package:flutter/material.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';
import 'form_step2.dart';

class FormStep1 extends StatefulWidget {
  const FormStep1({super.key});

  @override
  State<FormStep1> createState() => _FormStep1State();
}

class _FormStep1State extends State<FormStep1> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => FormStep2(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
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
              value: 0.25,
              backgroundColor: isDark ? AppColors.brand80 : AppColors.grey20,
              color: AppColors.brand70,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'What is your Name?',
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
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      hintText: 'First Name',
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
                            value!.isEmpty
                                ? 'Enter with your first name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      filled: true,
                      fillColor: isDark ? AppColors.grey80 : AppColors.grey10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter with your last name' : null,
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
              borderRadius: BorderRadius.circular(45),
            ),
          ),
          child: Text('Continue', style: AppTextStyles.button),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
