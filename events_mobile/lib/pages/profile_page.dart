import 'package:flutter/material.dart';
import '../../model/user.dart';
import '../../core/theme/color_style.dart';
import '../../core/theme/font_style.dart';

class ProfilePage extends StatelessWidget {
  final User userInProfilePage;

  const ProfilePage({super.key, required this.userInProfilePage});

  @override
  Widget build(BuildContext context) {
    final firstName = userInProfilePage.name.split(' ').first;
    final lastName = userInProfilePage.name.split(' ').last;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My details',
          style: AppTextStyles.heading.copyWith(
            color: isDark ? AppColors.grey40 : AppColors.grey60,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/avatars/1.png'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.accentIntenseDark : AppColors.accentMutedLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Change', style: AppTextStyles.button.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.brand60 : AppColors.brand60,
              )),
              ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionLabel('PERSONAL INFORMATION'),
          _buildProfileRow('First name', firstName,context),
          _buildProfileRow('Last name', lastName,context),
          _buildProfileRow('Location', userInProfilePage.locale,context),

          const SizedBox(height: 16),
          _buildSectionLabel('ACCOUNT INFORMATION'),
          _buildProfileRow('Email', userInProfilePage.email,context),
          
          const SizedBox(height: 16),
          _buildSectionLabel('INTERNATIONAL PREFERENCES'),
          _buildProfileRow('Language', 'English',context),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          //backgroundColor: AppColors.grey60,
          color: AppColors.grey50,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.accentStrongDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: isDark ? AppColors.textLight : AppColors.textDark),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: isDark ? AppColors.textLight : AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
