import 'package:events_mobile/pages/home/home_prestador.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:events_mobile/pages/home/home_organizador.dart';
import 'package:events_mobile/pages/welcome/welcome_page.dart';

class BaseHomePage extends StatefulWidget {
  const BaseHomePage({super.key});

  @override
  State<BaseHomePage> createState() => _BaseHomePageState();
}

class _BaseHomePageState extends State<BaseHomePage> {
  Map<String, dynamic>? userProfile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userProfile = doc.data();
          loading = false;
        });
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile!['tipo'] == 'organizador') {
      return HomeOrganizadorPage(userProfile: userProfile!);
    } else {
      return HomePrestador(userProfile: userProfile!);
    }
  }
}
