class User {
  late final String _name;
  late final String _email;
  late final String _password;
  late final String _location;

  //construtor
  User({required String nome, required String email, required String senha,required String locale})
    : _name = nome,
      _email = email,
      _password = senha,
      _location = locale;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get locale => _location;
}


