import 'package:events_mobile/widget/servicos/solicitacoes_servicos.dart';
import 'package:flutter/material.dart';
import 'package:events_mobile/services/auth_service.dart';
import 'package:events_mobile/pages/profile/profile_page.dart';
import 'package:events_mobile/widget/eventos/listar_eventos_organizador.dart';
import 'package:events_mobile/pages/welcome/welcome_page.dart';
import '../../../core/theme/color_style.dart';
import '../../../core/theme/font_style.dart';

class HomeOrganizadorPage extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const HomeOrganizadorPage({super.key, required this.userProfile});

  @override
  State<HomeOrganizadorPage> createState() => _HomeOrganizadorPageState();
}

class _HomeOrganizadorPageState extends State<HomeOrganizadorPage> {
  final _auth = AuthService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String nome = widget.userProfile['nome'] ?? '';
    final String email = widget.userProfile['email'] ?? '';

    final pages = [
      _buildHomePage(email),
      const ProfilePage(),  
      SolicitacoesServicos(emailOrganizador: email),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $nome', style: AppTextStyles.heading.copyWith(color: AppColors.textLight)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textLight),
            onPressed: () async {
              await _auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Solicitações'),
        ],
      ),
    );
  }

  Widget _buildHomePage(String email) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildCard(
            icon: Icons.event,
            title: 'Meus Eventos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeusEventosList(emailOrganizador: email),
                ),
              );
            },
          ),
          _buildCard(
            icon: Icons.pending_actions,
            title: 'Solicitações',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolicitacoesServicos(emailOrganizador: email),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.brand20,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.brandDark),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
