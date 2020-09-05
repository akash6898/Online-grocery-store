import 'package:flutter/material.dart';

class Profile {
  String _phoneNo;
  String _fName;
  String _lName;
  String _email;

  profilep(
      {@required String phoneNo,
      @required String fName,
      @required String lName,
      @required String email}) {
    _fName = fName;
    _lName = lName;
    _phoneNo = phoneNo;
    _email = email;
  }

  String get fName => _fName;

  String get lName => _lName;

  String get phoneNo => _phoneNo;

  String get email => _email;
}
