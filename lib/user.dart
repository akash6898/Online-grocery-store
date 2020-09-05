import 'package:flutter/material.dart';
import 'package:gmart/loading.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import './backend/product.dart';
import './model/profile.dart';

class User extends StatefulWidget {
  bool _isupdate;
  User([this._isupdate = false]);
  @override
  _User createState() {
    // TODO: implement createState
    return _User();
  }
}

class _User extends State<User> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _userData = {
    'Fname': null,
    'Lname': null,
    'email': null,
  };
  @override
  Widget build(BuildContext context) {
    final _logged = Provider.of<Logged>(context, listen: false);
    final _product = Provider.of<Product>(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: widget._isupdate ? Text("Edit Profile") : Text("Profile")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              if (!widget._isupdate)
                Center(
                    child: Text(
                  "Almost There!",
                  textScaleFactor: 1.7,
                )),
              if (!widget._isupdate)
                SizedBox(
                  height: 30,
                ),
              if (!widget._isupdate) Text("Help Us To Know You Better"),
              SizedBox(
                height: 30,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          initialValue: _logged.userInfo.fName,
                          decoration: InputDecoration(
                            labelText: "First Name",
                          ),
                          onSaved: (text) {
                            _userData['Fname'] = text;
                          },
                          validator: (text) {
                            if (text.isEmpty) {
                              return "please enter first name";
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: _logged.userInfo.lName,
                          decoration: InputDecoration(
                            labelText: "Last Name",
                          ),
                          onSaved: (text) {
                            _userData['Lname'] = text;
                          },
                          validator: (text) {
                            if (text.isEmpty) {
                              return "please enter last name";
                            }
                          },
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: _logged.userInfo.email,
                      decoration: InputDecoration(
                        labelText: "E-mail",
                      ),
                      onSaved: (text) {
                        _userData['email'] = text;
                      },
                      validator: (text) {
                        if (text.isEmpty ||
                            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                .hasMatch(text)) {
                          return "please enter a vaild email";
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  child: widget._isupdate
                      ? Text(
                          "Update",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        )
                      : Text(
                          "Start Shopping",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    _formKey.currentState.save();
                    if (_formKey.currentState.validate()) {
                      Get.dialog(Loading("Loading"), barrierDismissible: false);

                      if (widget._isupdate) {
                        _product.updateData(
                            "users", _logged.phoneNo, _userData);
                        bool a = await _logged.getData();
                        Get.back();
                        Get.back();
                      } else {
                        _userData['order_count'] = 0;

                        _logged.createRecord(_userData);
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
