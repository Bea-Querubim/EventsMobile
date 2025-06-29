import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
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
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}