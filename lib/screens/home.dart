import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:management/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference damageData =
      FirebaseFirestore.instance.collection('Damage');
  CollectionReference completionData =
      FirebaseFirestore.instance.collection('Complete');
  CollectionReference inProgressData =
      FirebaseFirestore.instance.collection('In-Progress');

  FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreReference = FirebaseFirestore.instance;
  bool showLoader = false,
      isUpload = false,
      isDataLoaded = false,
      dataUploaded = false,
      isSignuout = false;
  late String categorySelected;
  String? title, selectedWatt;
  var tempName;
  List<DropdownMenuItem> selectWatt = [];
  DateTime dateTime = DateTime.now();
  String? formattedDate;
  double valueForInProgressIndicator = 0,
      valueforDamageProgressIndicator = 0.0,
      valueforCompleteProgressIndicator = 0.0;

  var personName = TextEditingController();
  var materialSelected = TextEditingController();
  var dateText = TextEditingController();
  var enterQuantity = TextEditingController();
  var enterComments = TextEditingController();

  int finalTotalStock = 0;

  var companyDetail,
      damageStock,
      inProgress,
      totalStock,
      stockDetail,
      categoryName,
      deptDetail,
      finalStock;
  bool isDataNotAvailable = false;
  @override
  void initState() {
    categorySelected = "";
    dateText.text = dateTime.toString();
    getSelectedWatt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          categorySelected,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              splashRadius: 10,
              onPressed: () {
                setState(() {
                  isSignuout = true;
                });
                userSignOut();
              },
              icon: isSignuout == false
                  ? const Icon(
                      Icons.logout,
                      color: Colors.black,
                    )
                  : const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      )))
        ],
      ),
      body:
      Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: isDataLoaded == false
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
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
                          value: selectedWatt,
                          items: selectWatt,
                          onChanged: (value) {
                            setState(() {
                              if (selectedWatt!.isNotEmpty) {
                                selectedWatt = value.toString();
                              }
                              fetchData(selectedWatt!);
                            });
                          }),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    !isDataNotAvailable?Container(
                      child: Center(
                        child: Text("${title} is not available"),
                      ),
                    ):
                    isUpload == true
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.toString(),
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  categoryName.toString(),
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                const Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Company name:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(companyDetail.toString()),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.015,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Stock Details:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(stockDetail.toString()),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.015,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Department Details:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(deptDetail.toString()),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                const Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  'Item Detail:',
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Total Stock:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(finalTotalStock.toString()),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Available Stock:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(totalStock.toString()),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'In-Progress:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(inProgress.toString()),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                SizedBox(
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      value: valueForInProgressIndicator,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.yellow),
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Completed:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(finalStock.toString()),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                SizedBox(
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      value: valueforCompleteProgressIndicator,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.green),
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Damage Stock:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(damageStock.toString()),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                SizedBox(
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      value: valueforDamageProgressIndicator,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.red),
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Bounce(
                                      duration:
                                          const Duration(milliseconds: 110),
                                      onPressed: () {
                                        showInProgressDialog(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color(0xFF3F5185)),
                                        child: const Center(
                                          child: Text(
                                            "In-Progress",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Bounce(
                                      duration:
                                          const Duration(milliseconds: 110),
                                      onPressed: () {
                                        showCustomDialog(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color(0xFF3F5185)),
                                        child: const Center(
                                          child: Text(
                                            "Damage",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Bounce(
                                  duration: const Duration(milliseconds: 110),
                                  onPressed: () {
                                    showCompletionDialog(context);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: const Color(0xFF3F5185)),
                                    child: const Center(
                                      child: Text(
                                        "Complete",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }

  userSignOut() async {
    await auth.signOut().whenComplete(() => {
          showLoader = false,
          showSnackBar('Signed out successfully'),
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()))
        });
  }

  showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
    ));
  }

  fetchData(String watt) async {
    // DocumentSnapshot? reference = await FirebaseFirestore.instance
    //     .collection('Products')
    //     .doc(categorySelected.toString())
    //     .collection("categories")
    //     .doc(selectedWatt)
    //     .collection('parts')
    //     .doc(title)
    //     .get();

    QuerySnapshot categoryData = await firestoreReference
        .collection('Products')
        .doc(categorySelected)
        .collection('categories')
        .doc(selectedWatt)
        .collection('parts')
        .get();

    for (int i = 0; i < categoryData.docs.length; i++) {
      print(categoryData.docs[i].id.trim());
      if(title!.toLowerCase().trim()==categoryData.docs[i].id.trim().toLowerCase()){
        isDataNotAvailable = true;
        categoryName = categoryData.docs[i].get('categoryName');
        companyDetail = categoryData.docs[i].get('companyDetail');
        finalStock = categoryData.docs[i].get('completed');
        damageStock = categoryData.docs[i].get('damageStock');
        deptDetail = categoryData.docs[i].get('departmentDetail');
        inProgress = categoryData.docs[i].get('inProgress');
        totalStock = categoryData.docs[i].get('totalStock');
        stockDetail = categoryData.docs[i].get('stockDetail');

        isUpload = true;
        getValueForDamageProgress(damageStock);
        isDataLoaded = true;
        finalTotalStock = (damageStock + totalStock + finalStock + inProgress);
        getValueForProgress(inProgress);
        getValueForDamageProgress(damageStock);
        getValueForCompletionProgress(finalStock);
      }else{
        isDataNotAvailable = false;
      }
      setState(() {});
    }
  }

  getSelectedWatt() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    title = preferences.getString('materialSelected').toString();
    categorySelected = preferences.getString('categorySelected').toString();
    tempName = preferences.getString('name').toString();
    personName.text = tempName;
    materialSelected.text = title!;
    QuerySnapshot categoryData = await firestoreReference
        .collection('Products')
        .doc(categorySelected)
        .collection('categories')
        .get();

    for (int i = 0; i < categoryData.docs.length; i++) {
      selectWatt.add(DropdownMenuItem(
        value: categoryData.docs[i].id.toString(),
        child: Text(categoryData.docs[i].id.toString()),
      ));
    }
    selectedWatt = selectWatt.first.value;
    fetchData(selectedWatt!);
    setState(() {});
  }

  openDate() async {
    DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));

    if (newDate == null) {
      return;
    } else {
      setState(() {
        dateTime = newDate;
        dateText.text = dateTime.toString();
      });
    }
  }

  validateAndUploadData() async {
    showLoader = true;
    String? employerName, selectedMaterial, date, comments;
    int quantity = 0;

    if (enterQuantity.text == '') {
      enterQuantity.text = '0';
    }

    employerName = personName.text;
    selectedMaterial = materialSelected.text;
    date = dateText.text;
    quantity = int.parse(enterQuantity.text);
    comments = enterComments.text;

    if (date.trim().toString() == '' || quantity <= 0) {
      Fluttertoast.showToast(msg: 'Required fields are mandatory');
      showLoader = false;
    } else if (quantity > totalStock) {
      Fluttertoast.showToast(
          msg: 'Given quantity is more than the total stock');
      showLoader = false;
    } else {
      uploadDamageData(
          employerName, selectedMaterial, date, quantity, comments);
    }
  }

  uploadDamageData(String personName, String productName, String date,
      num damageQuantity, String comments) async {
    var updatedTotalStock = 0;

    DocumentReference updateData = await FirebaseFirestore.instance
        .collection('Products')
        .doc(categorySelected.toString())
        .collection("categories")
        .doc(selectedWatt)
        .collection('parts')
        .doc(title);

    updatedTotalStock = totalStock - damageQuantity;
    damageStock += damageQuantity;

    updateData.update({
      'damageStock': damageStock,
      'totalStock': updatedTotalStock
    }).whenComplete(() =>
        {fetchData(selectedWatt!), getValueForDamageProgress(damageStock)});
    setState(() {});
    damageData.add({
      'personName': personName,
      'productName': productName,
      'date': date,
      'damageQuantity': damageQuantity,
      'comments': comments,
      'itemSelected': categorySelected,
      'category': categoryName
    }).whenComplete(() => {
          showSnackBar('Data entered successfully.'),
          showLoader = false,
          Navigator.pop(context),
          fetchData(selectedWatt!)
        });
  }

  validateAndInProgressData() async {
    showLoader = true;
    String? employerName, selectedMaterial, date, comments;
    int quantity = 0;

    if (enterQuantity.text == '') {
      enterQuantity.text = '0';
    }

    employerName = personName.text;
    selectedMaterial = materialSelected.text;
    date = dateText.text;
    quantity = int.parse(enterQuantity.text);
    comments = enterComments.text;

    if (date.trim().toString() == '' || quantity <= 0) {
      Fluttertoast.showToast(msg: 'Required fields are mandatory');
      showLoader = false;
    } else if (quantity > totalStock) {
      Fluttertoast.showToast(msg: 'Enter data properly');
      showLoader = false;
    } else {
      uploadInProgressData(
          employerName, selectedMaterial, date, quantity, comments);
    }
  }

  uploadInProgressData(String employerName, String productName, String date,
      num quantity, String comments) async {
    var updatedTotalStock = 0;

    DocumentReference updateData = await FirebaseFirestore.instance
        .collection('Products')
        .doc(categorySelected.toString())
        .collection("categories")
        .doc(selectedWatt)
        .collection('parts')
        .doc(title);

    updatedTotalStock = totalStock - quantity;
    inProgress += quantity;

    updateData.update({
      'totalStock': updatedTotalStock,
      'inProgress': inProgress
    }).whenComplete(
        () => {fetchData(selectedWatt!), getValueForProgress(inProgress)});
    setState(() {});

    inProgressData.add({
      'personName': employerName,
      'productName': productName,
      'date': date,
      'inProgress': quantity,
      'category': categoryName,
      'itemSelected': categorySelected,
      'comments': comments
    }).whenComplete(() => {
          showSnackBar('Data entered successfully.'),
          fetchData(selectedWatt!),
          getValueForProgress(inProgress),
          showLoader = false,
          Navigator.pop(context),
        });
  }

  validateAndCompletionData() {
    showLoader = true;
    String? employerName, selectedMaterial, date, comments;
    int quantity = 0;

    if (enterQuantity.text == '') {
      enterQuantity.text = '0';
    }

    employerName = personName.text;
    selectedMaterial = materialSelected.text;
    date = dateText.text;
    quantity = int.parse(enterQuantity.text);
    comments = enterComments.text;

    if (date.trim().toString() == '' || quantity <= 0) {
      Fluttertoast.showToast(msg: 'Required fields are mandatory');
      showLoader = false;
    } else if (quantity > inProgress) {
      Fluttertoast.showToast(msg: 'Enter data properly');
      showLoader = false;
    } else {
      uploadCompletionData(
          employerName, selectedMaterial, date, quantity, comments);
    }
  }

  uploadCompletionData(String employerName, String productName, String date,
      num quantity, String comments) async {
    var updatedTotalStock = 0;

    DocumentReference updateData = await FirebaseFirestore.instance
        .collection('Products')
        .doc(categorySelected.toString())
        .collection("categories")
        .doc(selectedWatt)
        .collection('parts')
        .doc(title);

    updatedTotalStock = inProgress - quantity;
    finalStock += quantity;

    updateData.update({
      'inProgress': updatedTotalStock,
      'completed': finalStock
    }).whenComplete(() =>
        {fetchData(selectedWatt!), getValueForCompletionProgress(finalStock)});
    setState(() {});

    completionData.add({
      'personName': employerName,
      'productName': productName,
      'date': date,
      'completeQuantity': quantity,
      'category': categoryName,
      'itemSelected': categorySelected,
      'comments': comments
    }).whenComplete(() => {
          showSnackBar('Data entered successfully.'),
          fetchData(selectedWatt!),
          getValueForProgress(inProgress),
          showLoader = false,
          Navigator.pop(context),
        });
  }

  getValueForProgress(num updatedCompleteStock) {
    valueForInProgressIndicator =
        (((updatedCompleteStock * 100) / finalTotalStock / 100));
    setState(() {});
  }

  getValueForCompletionProgress(num finalStockUpdates) {
    valueforCompleteProgressIndicator =
        (((finalStockUpdates * 100) / finalTotalStock) / 100);
    setState(() {});
  }

  getValueForDamageProgress(num damageStockProgress) {
    valueforDamageProgressIndicator =
        (((damageStockProgress * 100) / finalTotalStock) / 100);
    setState(() {});
  }

  showCustomDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Material(
              borderRadius: BorderRadius.circular(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Damage',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Employee Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: personName,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Product Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: materialSelected,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: dateText,
                              onTap: () {
                                openDate();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: enterQuantity,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: enterComments,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xFF3F5185)),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          validateAndUploadData();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
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
                                    "Damage",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  showInProgressDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Material(
              borderRadius: BorderRadius.circular(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'In-Progress',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Employee Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: personName,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Product Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: materialSelected,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: dateText,
                              onTap: () {
                                openDate();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: enterQuantity,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: enterComments,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
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
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          validateAndInProgressData();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
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
                                    "In-Progress",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  showCompletionDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Material(
              borderRadius: BorderRadius.circular(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Complete',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Employee Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: personName,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Product Name',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: materialSelected,
                    enabled: false,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: dateText,
                              onTap: () {
                                openDate();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            TextField(
                              controller: enterQuantity,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  TextField(
                    controller: enterComments,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
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
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                      Bounce(
                        duration: const Duration(milliseconds: 110),
                        onPressed: () {
                          validateAndCompletionData();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
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
                                    "Complete",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }
}
