import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../loading.dart';
import '../model/profile.dart';

class Logged extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId;
  int token;
  User user;
  String text = '';
  String phoneNo;
  bool isLoggedIn;
  final databaseReference = FirebaseFirestore.instance;
  Profile userInfo = new Profile();

  void setPhoneNo(String phone) async {
    phoneNo = phone;
    verifyPhoneNumber();
  }

  Future<bool> getData() async {
    final usersRef = databaseReference.collection('users').doc(phoneNo);
    print("a");
    DocumentSnapshot _profile = await usersRef.get();
    if (!_profile.exists) {
      userInfo.profilep(phoneNo: null, fName: null, lName: null, email: null);
      //notifyListeners();
      return true;
    } else {
      userInfo.profilep(
          phoneNo: phoneNo,
          fName: _profile.data()['Fname'].toString(),
          lName: _profile.data()['Lname'].toString(),
          email: _profile.data()['email'].toString());
      notifyListeners();
      return false;
    }
  }

  void createRecord(data) async {
    final Map<String, dynamic> _data = data;
    try {
      await databaseReference.collection("users").doc(phoneNo).set({
        'Fname': _data['Fname'],
        'Lname': _data['Lname'],
        'email': _data['email'],
        'order_count': _data['order_count'],
      });
      Get.back();
      Get.offAllNamed('/');
    } catch (error) {
      Get.back();
      Get.dialog(
          AlertDialog(
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
          barrierDismissible: false);
    }
  }

  void verifyPhoneNumber([bool resend = false]) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      print('in complete');
      Get.dialog(Loading("Verifying your authentication code"),
          barrierDismissible: false);

      signInWithPhoneNumber(null, phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (Exception authException) {
      print("in failed");
      Get.back();
      Get.dialog(
          AlertDialog(
            title: Text(authException.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Done",
                  textScaleFactor: 1.2,
                ),
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
          barrierDismissible: false);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) {
      print("in codesent");
      _verificationId = verificationId;
      text = '';
      notifyListeners();
      token = forceResendingToken;
      Get.back();
      if (resend == false) {
        Get.toNamed('/otp');
      }
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('in autoretreif');
      _verificationId = verificationId;
    };

    await _auth
        .verifyPhoneNumber(
            phoneNumber: "+91" + phoneNo,
            timeout: const Duration(seconds: 15),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            forceResendingToken: token,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .catchError((error) {
      Get.dialog(
          AlertDialog(
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Get.back();
                  Get.back();
                  return;
                },
              )
            ],
          ),
          barrierDismissible: false);
    });
  }

  void signInWithPhoneNumber(String _smsCode,
      [PhoneAuthCredential credential]) async {
    if (_smsCode != null)
      credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCode,
      );

    try {
      user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        User currentUser = _auth.currentUser;
        assert(user.uid == currentUser.uid);
        bool _isNew = await getData();
        if (_isNew) {
          Get.offAllNamed('/user');
        } else {
          Get.offAllNamed('/');
        }
      }
    } catch (error) {
      text = '';
      notifyListeners();
      Get.dialog(
          AlertDialog(
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Get.back();
                  Get.back();
                  return;
                },
              )
            ],
          ),
          barrierDismissible: false);
    }
  }

  void logout() async {
    try {
      await _auth.signOut();
      _auth.authStateChanges().listen((firebaseUser) {
        user = firebaseUser;
        text = '';
        Get.offAllNamed('/');
      });
    } catch (error) {
      Get.dialog(
          AlertDialog(
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
          barrierDismissible: false);
    }
  }

  Future<bool> signedIn() async {
    user = _auth.currentUser;
    print("log");
    print(user);
    if (user != null) {
      phoneNo = user.phoneNumber.substring(3, 13);
      bool _isProfile = await getData();
      isLoggedIn = !_isProfile;
      //  notifyListeners();
      return true;
    }
    isLoggedIn = false;
    // notifyListeners();
    return true;
  }
}
