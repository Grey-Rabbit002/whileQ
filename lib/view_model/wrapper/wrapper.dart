import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:while_app/local_db/models/db_helper.dart';
import 'package:while_app/local_db/models/store_model.dart';
import 'package:while_app/repository/firebase_repository.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/view/auth/phone.dart';
import 'package:while_app/view/home_screen.dart';
import 'package:while_app/view/auth/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    print(firebaseUser);
    final googlesignin = context.read<FirebaseAuthMethods>().googleSignIn;
    print(firebaseUser == null);
    if (firebaseUser != null) {
      print(googlesignin);
      return googlesignin ? CircularProgressIndicator() : HomeScreen();
    } else {
      //return const MyPhone();
      return Consumer<FirebaseAuthMethods>(
        builder: (context, value, child) {
          // return Logi();
          print(googlesignin);
          return LoginScreen();
        },
      );
    }
  }
}
