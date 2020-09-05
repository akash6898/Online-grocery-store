import 'package:flutter/material.dart';
import 'package:gmart/loading.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'loading.dart';

class Otp extends StatefulWidget {
  @override
  _Otp createState() => _Otp();
}

class _Otp extends State<Otp> {
  TextEditingController _otpController = TextEditingController();
  int _length = 0;
  Timer _timer;
  int _start = 30;
  bool _resendButton = true;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            _resendButton = true;
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    final _logged = Provider.of<Logged>(context);

    if (_logged.text != '') {
      _otpController.text = _logged.text;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Verification Code"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.2),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child:
                            Text("Please check the OTP Sent to your mobile "),
                      ),
                      Center(
                        child: Text("number"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        child: Text(
                          "Enter OTP",
                        ),
                        alignment: Alignment.topLeft,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PinCodeTextField(
                        controller: _otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        pinBoxDecoration:
                            ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                        wrapAlignment: WrapAlignment.spaceEvenly,
                        pinBoxWidth: 30,
                        pinBoxHeight: 40,
                        autofocus: false,
                        onTextChanged: (text) {
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
                          child: Text(
                            "Done",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                          color: Theme.of(context).primaryColor,
                          elevation: 0,
                          onPressed: _length != 6 ? null : () => _done(_logged),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              _resendButton == true
                  ? GestureDetector(
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onTap: () => _resend(_logged),
                    )
                  : Text(
                      "Resend OTP in $_start seconds",
                      style: TextStyle(color: Colors.grey.shade700),
                    )
            ],
          ),
        ));
  }

  void _done(Logged _logged) {
    Get.dialog(Loading("Verifying your authentication code"),
        barrierDismissible: false);
    _logged.signInWithPhoneNumber(_otpController.text);
  }

  void _resend(Logged _logged) {
    _start = 30;
    _resendButton = false;
    startTimer();
    Get.dialog(Loading("Requesting verification code"),
        barrierDismissible: false);
    _logged.verifyPhoneNumber(true);
  }
}
