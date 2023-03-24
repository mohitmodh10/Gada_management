import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:management/screens/home.dart';
import 'package:management/screens/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  bool passwordVisible = false, hidePasswordText = true, showLoader = false;

  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF3F5185),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: SvgPicture.asset(
                  'lib/assets/svg/background.svg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.045,
                        ),
                        Text(
                          "Sign in",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Text(
                          "Welcome back, login to get access of your account",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        TextField(
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.emailAddress,
                          controller: loginEmail,
                          decoration: const InputDecoration(
                              hintText: "Email",
                              fillColor: Color(0x343F5185),
                              filled: true,
                              prefixIcon: Icon(Icons.email),
                              prefixIconColor: Color(0xFF3F5185),
                              border: InputBorder.none),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.name,
                          obscureText: hidePasswordText,
                          controller: loginPassword,
                          decoration: InputDecoration(
                              fillColor: const Color(0x343F5185),
                              filled: true,
                              border: InputBorder.none,
                              hintText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              prefixIconColor: const Color(0xFF3F5185),
                              suffixIcon: IconButton(
                                  splashRadius: 5,
                                  color: const Color(0xFF3F5185),
                                  iconSize: 20,
                                  onPressed: () {
                                    getPasswordVisible();
                                  },
                                  icon: Icon(passwordVisible == true
                                      ? Icons.visibility
                                      : Icons.visibility_off))),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Bounce(
                            duration: const Duration(milliseconds: 110),
                            onPressed: validateLoginData,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFF3F5185)),
                              child: Center(
                                child: showLoader == true
                                    ? const SizedBox(
                                        width: 30.0,
                                        height: 30.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                          color: Colors.white,
                                        ))
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('New to app?'),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegistrationScreen()));
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                        color: Color(0xFF3F5185),
                                        fontWeight: FontWeight.w700),
                                  ))
                            ],
                          ),
                        )
                      ]))
            ],
          ),
        ),
      ),
    );
  }

  validateLoginData() {
    final bool validEmail = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(loginEmail.text);
    if (loginEmail.text.trim() == "" || loginPassword.text.trim() == "") {
      showSnackBar('Field is mandatory');
    } else if (validEmail == false) {
      showSnackBar('Email is not valid');
    } else {
      signInData();
    }
  }

  getPasswordVisible() {
    setState(() {
      if (passwordVisible == false) {
        passwordVisible = true;
      } else {
        passwordVisible = false;
      }

      if (passwordVisible == true) {
        hidePasswordText = false;
      } else {
        hidePasswordText = true;
      }
    });
  }

  signInData() async {
    setState(() {
      showLoader = true;
    });
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: loginEmail.text, password: loginPassword.text);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar('There is no acount, Try again with diffenent email');
        setState(() {
          showLoader = false;
        });
      } else if (e.code == 'wrong-password') {
        showSnackBar('Check your password and try again');
        setState(() {
          showLoader = false;
        });
      }
    } catch (e) {
      showSnackBar(e.toString());
      setState(() {
        showLoader = false;
      });
    }

    if (user != null) {
      Query reference = FirebaseFirestore.instance
          .collection('Users')
          .where("email", isEqualTo: user!.email);
      QuerySnapshot data = await reference.get();
      setState(() {
        showLoader = false;
      });
      showSnackBar('Signed In Successfully');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('name', data.docs[0]['name']);
      preferences.setString(
          'categorySelected', data.docs[0]['category_selected']);
      preferences.setString(
          'materialSelected', data.docs[0]['material_selected']);
    }
  }

  showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
    ));
  }
}
