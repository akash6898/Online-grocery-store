import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmart/loading.dart';
import './backend/product.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'showdate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateTIme extends StatefulWidget {
  @override
  _DateTime createState() {
    // TODO: implement createState
    return _DateTime();
  }
}

class _DateTime extends State<DateTIme> {
  List<String> _dateList = [];
  int index1 = 0;
  List<String> _timeList = [];
  int index2 = 0;

  @override
  void initState() {
    _dateList.add("choose date");
    var now = new DateTime.now();
    var t = new DateFormat("yyyy-MM-dd hh:mm:ss", "en_US").format(now);
    var date1 = DateTime.parse(t);
    for (int i = 0; i < 4; i++) {
      var date2 = date1.add(new Duration(days: i));
      var u = new DateFormat("dd MMMM yyyy", "en_US").format(date2);
      _dateList.add(u.toString());
    }
    print(_dateList);
    _timeList.add("choose time");
    _timeList.add("9AM - 11AM");
    _timeList.add("11AM - 1PM");
    _timeList.add("1PM - 3PM");
    _timeList.add("3PM - 5PM");
    _timeList.add("5PM - 7PM");
    _timeList.add("7PM - 9PM");
    _timeList.add("9PM - 11PM");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _logged = Provider.of<Logged>(context, listen: false);
    print(_product.cartMrp);
    print(_product.cartPrice);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Date and Time"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Delivery date"),
                  Text(_dateList[index1]),
                ],
              ),
              onPressed: () async {
                int a = await Get.to(ShowDate(_dateList, index1, true));
                if (a != null)
                  setState(() {
                    index1 = a;
                  });
              },
            ),
            SizedBox(
              height: 20,
            ),
            FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Delivery time"),
                  Text(_timeList[index2]),
                ],
              ),
              onPressed: () async {
                int a = await Get.to(ShowDate(_timeList, index2, false));
                if (a != null)
                  setState(() {
                    index2 = a;
                  });
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.all(0),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          if (index1 > 0 && index2 > 0) {
            Get.dialog(Loading("Loading"), barrierDismissible: false);
            final _ref = _product.databaseReference.collection('orders').doc();

            DocumentReference _couponRef;

            if (_product.coupon != null) {
              _couponRef = _product.databaseReference
                  .collection("coupons")
                  .doc(_product.coupon.id)
                  .collection("redeemd")
                  .doc(_logged.user.phoneNumber.substring(3));
            }

            final _userRef = _product.databaseReference
                .collection("users")
                .doc(_logged.user.phoneNumber.substring(3));
            int _itemCount = 0;
            _product.item.forEach((element) {
              _itemCount = _itemCount + element['quantity'];
            });
            Map<String, dynamic> _data = {
              'ordered on': FieldValue.serverTimestamp(),
              'address': _product.address,
              'delivery date': _dateList[index1],
              'delivery time': _timeList[index2],
              'status': "Placed",
              'items': _product.item.toList(),
              'price': _product.cartPrice,
              'mrp': _product.cartMrp,
              'subtotal': _product.subtotal,
              'user': _logged.user.phoneNumber.substring(3),
              'delivery charges': _product.deliveryCharges.toString(),
              'itemCount': _itemCount,
              'coupon':
                  _couponRef != null ? _product.coupon.data()['name'] : null,
              'discount': _product.discount,
            };
            try {
              await _product.databaseReference.runTransaction(
                  (transcation) async {
                if (_couponRef != null) {
                  DocumentSnapshot _document =
                      await transcation.get(_couponRef);
                  if (!_document.exists) {
                    transcation.set(_couponRef, {"order_count": 1});
                  } else {
                    transcation.update(
                        _couponRef, {"order_count": FieldValue.increment(1)});
                  }
                }
                transcation
                    .update(_userRef, {"order_count": FieldValue.increment(1)});
                return transcation.set(_ref, _data);
              }, timeout: Duration(seconds: 10)).then((onValue) async {
                _product.orderDetials = await _ref.get();
                print(_product.orderDetials.data);
                await _product.deleteCart();
                Get.back();
                Get.toNamed('/thanku');
              }).catchError((error) {
                print("b");
                Get.back();
                Get.dialog(
                    AlertDialog(
                      title: Text(error.toString()),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("ok"),
                          onPressed: () {
                            Get.back();
                          },
                        )
                      ],
                    ),
                    barrierDismissible: false);
              });
            } catch (error) {
              print("c");
              Get.back();
              Get.dialog(
                  AlertDialog(
                    title: Text(error.toString()),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("ok"),
                        onPressed: () {
                          Get.back();
                        },
                      )
                    ],
                  ),
                  barrierDismissible: false);
            }
          } else {
            Get.dialog(
                AlertDialog(
                  content: Text("Please choose vaild date and time"),
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
        },
        child: Container(
          height: 50,
          child: Center(
              child: Text(
            "Procced To Payment",
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          )),
        ),
      ),
    );
  }
}
