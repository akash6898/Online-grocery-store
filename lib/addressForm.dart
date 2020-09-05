import 'package:flutter/material.dart';
import 'package:gmart/loading.dart';
import 'package:gmart/showdate.dart';
import './backend/product.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class AddressForm extends StatelessWidget {
  List<dynamic> _data = [];
  int _index;
  AddressForm(List<dynamic> _address, this._index) {
    if (_address == null) {
      _data = [];
    } else {
      _data = new List.from(_address);
    }
  }
  final Map<String, dynamic> _address = {
    'name': null,
    'house': null,
    'street': null,
    'locality': null,
    'contactNo': null,
  };
  final _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _logged = Provider.of<Logged>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Adrress"),
      ),
      body: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                    //boxShadow: [
                    //BoxShadow(
                    //color: Colors.grey,
                    //offset: Offset(0.0, 1.0), //(x,y)
                    //blurRadius: 6.0,
                    //),
                    //],
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      initialValue: _index != -1 ? _data[_index]['name'] : "",
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(0),
                        labelText: "Name",
                      ),
                      validator: (text) {
                        if (text.length <= 0) {
                          return "Invaild";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        _address['name'] = text;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: _index != -1 ? _data[_index]['house'] : "",
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(0),
                          labelText: "House No"),
                      validator: (text) {
                        if (text.length <= 0) {
                          return "Invaild";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        _address['house'] = text;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: _index != -1 ? _data[_index]['street'] : "",
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(0),
                          labelText: "Street"),
                      validator: (text) {
                        if (text.length <= 0) {
                          return "Invaild";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        _address['street'] = text;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue:
                          _index != -1 ? _data[_index]['locality'] : "",
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(0),
                          labelText: "locality"),
                      validator: (text) {
                        if (text.length <= 0) {
                          return "Invaild";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        _address['locality'] = text;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue:
                          _index != -1 ? _data[_index]['contactNo'] : "",
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(0),
                        labelText: "contactNo",
                      ),
                      validator: (text) {
                        if (text.length <= 0) {
                          return "Invaild";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        _address['contactNo'] = text;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        child: Text(
                          "Save Address",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          _formKey.currentState.save();
                          if (_formKey.currentState.validate()) {
                            if (_index == -1) {
                              _data.add(_address);
                            } else {
                              _data[_index] = _address;
                            }
                            Get.dialog(Loading("Loading"),
                                barrierDismissible: false);
                            _product.updateData(
                                'users',
                                _logged.user.phoneNumber.substring(3),
                                {'addresses': _data});
                            Get.back();
                            Get.back();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
