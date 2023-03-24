import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:management/screens/home.dart';
import 'package:management/screens/registration.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;
  runApp(MaterialApp(
    home: user == null ? const RegistrationScreen() : const HomeScreen(),
  ));
}
