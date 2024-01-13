import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:while_app/view/home_screen.dart';
import 'package:while_app/view/auth/login_screen.dart';
// import 'package:while_app/resources/components/message/apis.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    try {
      if (firebaseUser != null) {
        // print(APIs.me.email);
        return const HomeScreen();
      } else {
        return const LoginScreen();
      }
    } catch (e) {
      rethrow;
    }
  }
}
