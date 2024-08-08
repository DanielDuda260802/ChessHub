import 'dart:convert';
import 'dart:io';

import 'package:chesshub/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _uid;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  UserModel? get userModel => _userModel;
  String? get uid => _uid;

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setIsSignedIn({required bool value}) {
    _isSignedIn = value;
    notifyListeners();
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // CREATE USER:

  // email + password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection(Constants.users).doc(uid).get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future getUserDataFromFirestore() async {
    await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      _userModel =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      _uid = _userModel!.uid;
      notifyListeners();
    });
  }

  Future saveUserToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  Future getUserFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString(Constants.userModel) ?? '';

    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;

    notifyListeners();
  }

  Future setSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(Constants.isSignedIn, true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future<bool> checkIfSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isSignedIn = sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  // SIGN IN
  // email + password
  Future<UserCredential?> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential =
        await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  void saveUserDataToFirestore({
    required UserModel currentUser,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      if (fileImage != null) {
        // upload image to firestore storage
        String imageUrl = await storeImageToFirestore(
          ref: '${Constants.userImage}/$uid.jpg',
          file: fileImage,
        );

        currentUser.image = imageUrl;
      }

      currentUser.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
      _userModel = currentUser;

      // save data to firestore
      await firebaseFirestore
          .collection(Constants.users)
          .doc(uid)
          .set(currentUser.toMap());

      onSuccess();
      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  Future<String> storeImageToFirestore({
    required String ref,
    required File file,
  }) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot taskSnapShot = await uploadTask;
    String downloadUrl = await taskSnapShot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await firebaseAuth.signOut();
    _isSignedIn = false;
    sharedPreferences.clear();
    notifyListeners();
  }
}
