import 'package:flutter/material.dart';
import '../core/theme/color_style.dart';
import '../core/theme/font_style.dart';
import '../widget/caroussel_welcome.dart';
import '../app/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: 'events',
                      style: TextStyle(
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    const TextSpan(
                      text: 'Mobile',
                      style: TextStyle(
                        color: AppColors.brand60,
                      ),
                    ),
                  ],
                ),
              ),

              const CarousselWelcome(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/form');
                },
                child: Text(
                  'Create account',
                  style: AppTextStyles.button,
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Have an account? Log in',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.brand70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
