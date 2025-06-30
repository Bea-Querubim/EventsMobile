import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';
import '../../model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? profile;
  bool loading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(currentUser.uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          profile = UserProfile(
            nome: data['nome'] ?? '',
            email: data['email'] ?? '',
            senha: data['senha'] ?? '',
            telefone: data['telefone'] ?? 0,
            tipo:
                data['tipo'] == 'organizador'
                    ? TipoUsuario.organizador
                    : TipoUsuario.prestador,
          );
          loading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final directory =
          await getApplicationDocumentsDirectory(); // Pasta local do app
      final String fileName = path.basename(pickedFile.path);
      final File localImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$fileName');

      setState(() {
        _imageFile = localImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final firstName = profile!.nome.split(' ').first;
    final lastName = profile!.nome.split(' ').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu perfil',
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/images/avatars/1.png')
                              as ImageProvider,
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark
                            ? AppColors.accentIntenseDark
                            : AppColors.accentMutedLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Alterar foto',
                    style: AppTextStyles.button.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.brand60,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionLabel('INFORMAÇÕES PESSOAIS'),
          _buildProfileRow('Nome', profile!.nome, context),
          _buildProfileRow('Telefone', profile!.telefone.toString(), context),

          const SizedBox(height: 16),
          _buildSectionLabel('CONTA'),
          _buildProfileRow('Email', profile!.email, context),
          _buildProfileRow(
            'Tipo de usuário',
            profile!.tipo == TipoUsuario.organizador
                ? 'Organizador'
                : 'Prestador de serviços',
            context,
          ),
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
          color: AppColors.grey50,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, BuildContext context) {
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
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
