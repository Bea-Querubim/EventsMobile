import 'package:flutter/material.dart';
import '../pages/forms/produtos/criar_produtos.dart';
import '../pages/forms/servicos/criar_servicos.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/relatorios/relatorios.dart';
import '../pages/signup/signup_page.dart';
import '../widget/eventos/buscar_eventos.dart';
import '../widget/eventos/listar_eventos_organizador.dart';
import '../widget/eventos/listar_eventos_prestador.dart';
import '../widget/servicos/listar_servicos.dart';

class AppRoutes {
  static const String sign = '/sign';
  static const String login = '/login';
  static const String home = '/home';
  static const String criarServicos = '/criar-servicos';
  static const String cadastrarProdutos = '/cadastrar-produtos';
  static const String buscarEventos = '/buscar-eventos';
  static const String servicos = '/servicos';
  static const String relatorios = '/relatorios';
  static const String listarEventosOrganzador = '/listar-eventos';
  static const String listarEventosPrestador = '/listar-meus-eventos';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case sign:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const BaseHomePage());
      case criarServicos:
        return MaterialPageRoute(builder: (_) => const CriarServicos());
      case servicos:
        final email = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => MeusServicosList(emailPrestador: email));
      case listarEventosOrganzador:
        final email = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => MeusEventosList(emailOrganizador: email));
      case cadastrarProdutos:
        return MaterialPageRoute(builder: (_)=> const CriarProduto());
      case buscarEventos:
        return MaterialPageRoute(builder: (_)=> const EventosDisponiveisList()); 
      case relatorios:
        return MaterialPageRoute(builder: (_)=> const RelatorioServicos());
      case listarEventosPrestador:
        final email = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ListarEventosPrestador(usuarioEmail: email));
      

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(child: Text('Rota não encontrada')),
                ));
    }
  }
}
