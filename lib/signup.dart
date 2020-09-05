import 'dart:ui';
import 'package:flutter/material.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'loading.dart';

class signup extends StatefulWidget {
  @override
  _signup createState() => _signup();
}

class _signup extends State<signup> {
  TextEditingController _phoneNumberController = TextEditingController();
  int _length = 0;
  @override
  Widget build(BuildContext context) {
    final _logged = Provider.of<Logged>(context);
    var size = MediaQuery.of(context).size;
    double width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(width: 0.2),
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white),
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "We will send an SMS with a confirmation code to this number",
                    textScaleFactor: 1.1,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    hintText: "Phone Number",
                    fillColor: Colors.white,
                  ),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: (text) {
                    setState(() {
                      _length = text.length;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: width,
                    height: 40,
                    child: RaisedButton(
                        elevation: 0,
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'Next',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                        onPressed:
                            _length != 10 ? null : () => _onClick(_logged))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onClick(Logged _logged) {
    Get.dialog(
        Loading(
          "Requesting verification code",
        ),
        barrierDismissible: false);
    _logged.setPhoneNo(_phoneNumberController.text);
    _phoneNumberController.text = '';
  }
}
