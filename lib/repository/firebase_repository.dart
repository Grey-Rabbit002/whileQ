// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:while_app/resources/components/message/apis.dart';
import 'package:while_app/resources/components/message/models/chat_user.dart';
import '../utils/utils.dart';

class FirebaseAuthMethods extends ChangeNotifier {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  User get user => _auth.currentUser!;
  ChatUser newUser = ChatUser(
    image: 'image',
    about: 'about',
    name: 'name',
    createdAt: 'createdAt',
    isOnline: false,
    id: 'id',
    lastActive: 'lastActive',
    email: 'email',
    pushToken: 'pushToken',
    dateOfBirth: '',
    gender: '',
    phoneNumber: '',
    place: '',
    profession: '',
    designation: 'Member',
    follower: 0,
    following: 0,
  );

  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();
  bool _googleSign = false;
  bool get googleSignIn => _googleSign;
  Future signInWithEmailAndPassword(
      String email, String password, String name, BuildContext context) async {
    try {
      Utils.snackBar("verify mail ", context);

      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        newUser.email = email;
        newUser.name = name;
        newUser.about = 'Hey I My name is $name , connect me at $email';
        log('/////as////${_auth.currentUser!.uid}');
      });
      await sendemailverification(context);
      await APIs.createNewUser(newUser);
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
    }
  }

  Future<void> sendemailverification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message.toString(), context);
    }
  }

  Future<void> loginInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      // print("trying sign in");
      // print(_auth.currentUser!.emailVerified);
      // print(_auth.currentUser!.emailVerified);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
    }
  }

  Future signout(BuildContext context) async {
    try {
      _googleSign = false;
      notifyListeners();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      Utils.snackBar(e.message!, context);
    }
  }

  Future<DocumentSnapshot> getSnapshot() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser?.uid)
        .get();
    return snapshot;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out to force account selection prompt
      _googleSign = true;
      notifyListeners();
      await GoogleSignIn().signOut();
      Utils.snackBar("Sign Up Prompt", context);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          Utils.snackBar("Sign Up Complete", context);
          if (userCredential.additionalUserInfo!.isNewUser) {
            newUser.email = userCredential.user!.email!;
            newUser.name = userCredential.user!.displayName!;
            newUser.about =
                'Hey I My name is ${newUser.name} , connect me at ${newUser.email}';
            log('/////as////${_auth.currentUser!.uid}');
            await APIs.createNewUser(newUser);
            // await APIs.getSelfInfo();
          }
        }
      }
    } catch (e) {
    } finally {
      _googleSign = false;
      notifyListeners();
    }
  }
}
