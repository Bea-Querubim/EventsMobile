import '../pages/welcome_page.dart';
import '../pages/login/login_cel_number.dart';
import '../pages/login/login_email.dart';
import '../pages/forms/form_step1.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String form = '/form';
  static const String login = '/login';
  static const String loginEmail = '/login/email';

  static final routes = {
    welcome: (context) => const WelcomePage(),
    form: (context) => const FormStep1(), 
    login: (context) => const LoginCellNumber(),
    loginEmail: (context) => const LoginEmail(),
  };
}
