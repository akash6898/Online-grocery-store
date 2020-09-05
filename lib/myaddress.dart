import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './backend/product.dart';
import './backend/signin.dart';
import './model/profile.dart';
import 'package:get/get.dart';
import 'dart:async';

class MyAddress extends StatelessWidget {
  bool _ischeckout;

  MyAddress(this._ischeckout);
  List<dynamic> addressData = [];
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _logged = Provider.of<Logged>(context, listen: false);
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title:
              _ischeckout == true ? Text("Select Address") : Text("My Address"),
        ),
        backgroundColor: Colors.grey.shade200,
        body: StreamBuilder<DocumentSnapshot>(
          stream: _product
              .getData('users')
              .doc(_logged.user.phoneNumber.substring(3))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.data.data()['addresses'] == null) {
                return Center(
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 5),
                        Text("Add a new address"),
                      ],
                    ),
                    onPressed: () {
                      Get.toNamed('/addressForm',
                          arguments: {'data': null, 'index': -1});
                    },
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.data()['addresses'].length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_circle_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 5),
                              Text("Add new address"),
                            ],
                          ),
                          onPressed: () {
                            Get.toNamed('/addressForm', arguments: {
                              'data': snapshot.data.data()['addresses'],
                              'index': -1,
                            });
                          },
                        );
                      }

                      return Card(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              //boxShadow: [
                              //BoxShadow(
                              //color: Colors.grey,
                              //offset: Offset(0.0, 1.0), //(x,y)
                              //blurRadius: 6.0,
                              //),
                              //],
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 0.2),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              )),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.person),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(snapshot.data.data()['addresses']
                                              [index - 1]['name']),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.location_on),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                              child: Container(
                                                  child: Text(
                                            snapshot.data.data()['addresses']
                                                    [index - 1]['house'] +
                                                "," +
                                                snapshot.data
                                                        .data()['addresses']
                                                    [index - 1]['street'] +
                                                "," +
                                                snapshot.data
                                                        .data()['addresses']
                                                    [index - 1]['locality'],
                                            softWrap: true,
                                          ))),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.phone),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(snapshot.data.data()['addresses']
                                              [index - 1]['contactNo']),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _ischeckout == true
                                  ? FlatButton(
                                      child: Text(
                                        "Ship Here",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        _product.address = snapshot.data
                                            .data()['addresses'][index - 1];
                                        Get.toNamed('/choosetime');
                                      },
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                          icon: Icon(Icons.more_vert),
                                          items: ['Edit', 'Delete']
                                              .map((String value) {
                                            return new DropdownMenuItem(
                                              value: value,
                                              child: new Container(
                                                child: Text(value),
                                                width: 50,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String value) {
                                            if (value == 'Edit') {
                                              Get.toNamed('/addressForm',
                                                  arguments: {
                                                    'data': snapshot.data
                                                        .data()['addresses'],
                                                    'index': index - 1,
                                                  });
                                            } else {
                                              Get.dialog(AlertDialog(
                                                title: Text("Delete Address?"),
                                                content: const Text(
                                                    "Are you sure you want to delete this address?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                      onPressed: () {
                                                        addressData = List.from(
                                                            snapshot.data
                                                                    .data()[
                                                                'addresses']);
                                                        addressData.removeAt(
                                                            index - 1);
                                                        _product.updateData(
                                                            'users',
                                                            _logged.user
                                                                .phoneNumber
                                                                .substring(3),
                                                            {
                                                              'addresses':
                                                                  addressData
                                                            });
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      )),
                                                  FlatButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "No",
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                ],
                                              ));

                                              //Get.offNamed('/myaddress',
                                              //arguments: {'checkout': false});
                                            }
                                          }),
                                    ),
                            ],
                          ),
                        ),
                      );
                    });
              }
            }
          },
        ));
  }
}
