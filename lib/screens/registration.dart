import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:management/screens/home.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:management/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseFirestore.instance;
  CollectionReference reference =
      FirebaseFirestore.instance.collection('Users');
  List<DropdownMenuItem> category = [];
  List<DropdownMenuItem> itemMaterial = [];
  String? categoryDropDownValue = ' ', itemMaterialDropDownValue = ' ';
  TextEditingController personName = TextEditingController();
  TextEditingController personEmail = TextEditingController();
  TextEditingController personPassword = TextEditingController();

  bool emailExists = false,
      passwordVisible = false,
      hidePasswordText = true,
      showLoader = false,
      isAccountCreated = false,
      isdataLoaded = false;

  late String errorDesp;

  @override
  void initState() {
    errorDesp = "";
    getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF3f5185),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: isdataLoaded == false
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
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
                      height: MediaQuery.of(context).size.height * 0.75,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(225, 255, 255, 255),
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
                            "Sign up",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey[900],
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                          Text(
                            "Hello there! Sign up to continue",
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
                            keyboardType: TextInputType.name,
                            controller: personName,
                            decoration: const InputDecoration(
                                hintText: "Name",
                                fillColor: Color(0x343F5185),
                                filled: true,
                                prefixIcon: Icon(Icons.person),
                                prefixIconColor: Color(0xFF3F5185),
                                border: InputBorder.none),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.emailAddress,
                            controller: personEmail,
                            decoration: const InputDecoration(
                                hintText: "Email",
                                filled: true,
                                fillColor: Color(0x343F5185),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.email),
                                prefixIconColor: Color(0xFF3F5185)),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.name,
                            obscureText: hidePasswordText,
                            controller: personPassword,
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
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              color: const Color(0x343F5185),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: DropdownButton(
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  dropdownColor: Colors.grey[200],
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: Color(0xFF3F5185),
                                  ),
                                  value: categoryDropDownValue,
                                  items: category,
                                  onChanged: (value) {
                                    setState(() {
                                      if (categoryDropDownValue!.isNotEmpty) {
                                        categoryDropDownValue =
                                            value.toString();
                                      }

                                      getMaterial(categoryDropDownValue!);
                                    });
                                  })),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            color: const Color(0x343F5185),
                            child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: Color(0xFF3F5185),
                                ),
                                value: itemMaterialDropDownValue,
                                items: itemMaterial,
                                onChanged: (value) {
                                  setState(() {
                                    if (itemMaterialDropDownValue!.isNotEmpty) {
                                      itemMaterialDropDownValue =
                                          value.toString();
                                    }
                                  });
                                }),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Bounce(
                              duration: const Duration(milliseconds: 110),
                              onPressed: getDataValidate,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFF3F5185)),
                                child: Center(
                                  child: showLoader == true
                                      ? const SizedBox(
                                          height: 30.0,
                                          width: 30.0,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3.0,
                                          ),
                                        )
                                      : const Text(
                                          "Create Account",
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already, have an account?'),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()));
                                    },
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(
                                          color: Color(0xFF3F5185),
                                          fontWeight: FontWeight.w700),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  getDataValidate() {
    final bool validEmail = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(personEmail.text);
    if (personName.text.trim() == "" ||
        personEmail.text.trim() == "" ||
        personPassword.text.trim() == "") {
      showSnackBar("Field is mandatory");
    } else if (validEmail == false) {
      showSnackBar("Enter valid email");
    } else if (personPassword.text.length < 8) {
      showSnackBar("Password should be more than 8 characters");
    } else {
      uploadData();
    }
  }

  uploadData() async {
    setState(() {
      showLoader = true;
    });
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: personEmail.text, password: personPassword.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showSnackBar('Email already exists!');
        setState(() {
          showLoader = false;
        });
        emailExists = true;
      } else if (e.code == 'weak-password') {
        showSnackBar('Password is too weak');
        emailExists = true;
        setState(() {
          showLoader = false;
        });
      } else {
        emailExists = false;
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

    if (emailExists == false) {
      addUser();
    } else {
      emailExists = false;
    }
  }

  addUser() async {
    await reference.add({
      'name': personName.text,
      'email': personEmail.text,
      'category_selected': categoryDropDownValue,
      'material_selected': itemMaterialDropDownValue,
    }).whenComplete(() => {
          isAccountCreated = true,
          showLoader = false,
          showSnackBar("Account Created Successfully"),
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()))
        });

    if (isAccountCreated != false) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('name', personName.text);
      preferences.setString('categorySelected', categoryDropDownValue!);
      preferences.setString('materialSelected', itemMaterialDropDownValue!);
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

  showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
    ));
  }

  getCategory() async {
    QuerySnapshot categoryData =
        await databaseReference.collection('parts').get();
    for (int i = 0; i < categoryData.docs.length; i++) {
      print(categoryData.docs[i].id);
      category.add(DropdownMenuItem(
        value: categoryData.docs[i].id.toString(),
        child: Text(categoryData.docs[i].id.toString()),
      ));
    }
    categoryDropDownValue = category.first.value;
    setState(() {});
    getMaterial(categoryDropDownValue!);
  }

  getMaterial(String category) async {
    itemMaterial.clear();
    DocumentSnapshot materialData =
        await databaseReference.collection('parts').doc(category).get();
    if (materialData.data().toString() != "{}") {
      List data = materialData['parts'];
      for (int i = 0; i < data.length; i++) {
        itemMaterial.add(DropdownMenuItem(
          value: materialData['parts'][i].toString(),
          child: Text(materialData['parts'][i].toString()),
        ));
      }
    }
    itemMaterialDropDownValue =
        itemMaterial.isEmpty ? null : itemMaterial.first.value;
    setState(() {});
    isdataLoaded = true;
  }
}
