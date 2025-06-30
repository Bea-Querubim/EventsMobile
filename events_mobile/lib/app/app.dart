import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/theme.dart';
import '../pages/welcome/welcome_page.dart';
import '../pages/home/home_page.dart';
import 'routes.dart';

class EventsMobile extends StatelessWidget {
  const EventsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events Mobile',
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRoutes.generateRoute,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const WelcomePage();
          }
          // Se estiver logado, carrega a BaseHomePage que direciona internamente
          return const BaseHomePage();
        },
      ),
    );
  }
}
