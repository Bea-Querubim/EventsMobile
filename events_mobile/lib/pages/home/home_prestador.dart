import 'package:flutter/material.dart';
import '../../core/theme/font_style.dart';
import '../../core/theme/color_style.dart';
import '../../services/auth_service.dart';
import '../profile/profile_page.dart';
import '../welcome/welcome_page.dart';

class HomePrestador extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  const HomePrestador({super.key, required this.userProfile});

  @override
  State<HomePrestador> createState() => _HomePrestadorState();
}

class _HomePrestadorState extends State<HomePrestador> {
  int _selectedIndex = 0;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final List<Widget> pages = [
      _buildDashboard(context, primaryColor),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Bem-vindo, ${widget.userProfile['nome']}!',
          style: AppTextStyles.heading.copyWith(color: AppColors.textLight),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppColors.textLight,
            onPressed: () async {
              await _auth.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.grey60,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Color primaryColor) {
    final List<_GridItem> items = [
      _GridItem(Icons.add_circle, 'Criar Serviço', '/criar-servicos'),
      _GridItem(Icons.fastfood, 'Cadastrar Produtos', '/cadastrar-produtos'),
      _GridItem(Icons.search, 'Buscar Eventos', '/buscar-eventos'),
      _GridItem(Icons.list_alt, 'Meus Serviços', '/servicos', requiresEmail: true),
      _GridItem(Icons.bar_chart, 'Relatório Financeiro', '/relatorios'),
      _GridItem(Icons.calendar_today, 'Meus Eventos', '/listar-meus-eventos', requiresEmail: true),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: items.map((item) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (item.requiresEmail) {
                Navigator.pushNamed(context, item.route, arguments: widget.userProfile['email']);
              } else {
                Navigator.pushNamed(context, item.route);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 40, color: primaryColor),
                  const SizedBox(height: 12),
                  Text(item.label, style: AppTextStyles.body, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String route;
  final bool requiresEmail;

  _GridItem(this.icon, this.label, this.route, {this.requiresEmail = false});
}
