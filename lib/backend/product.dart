import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:gmart/datetime.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';

class Product extends ChangeNotifier {
  final databaseReference = FirebaseFirestore.instance;

  List<Map<String, dynamic>> cart = [];
  int subtotal = 0;
  int cartMrp;
  int cartPrice;
  int totalItemCount = 0;
  int deliveryCharges = 0;
  int minAmount = 0;
  Map<dynamic, dynamic> address;
  DocumentSnapshot orderDetials;
  Set<Map<String, dynamic>> item = new Set();
  int discount = 0;
  String phoneNo;
  RemoteConfig _remoteConfig;
  DocumentSnapshot coupon;
  String call;
  String email;
  Product(remoteConfig) {
    _remoteConfig = remoteConfig;
    call = _remoteConfig.getString("call");
    email = _remoteConfig.getString("email");
    setCart();
  }

  Future<String> getCoupon(String code) async {
    String error;
    QuerySnapshot _query = await getData("coupons")
        .where("name", isEqualTo: code)
        .get(GetOptions(source: Source.server))
        .catchError((onerror) {
      error = onerror.toString();
    });
    if (error != null) {
      return error;
    }
    if (_query.docs.length == 1) {
      coupon = _query.docs[0];
      String message = await check();

      if (message != "ok") {
        coupon = null;
        discount = 0;
        return message;
      }
      discountCalculation();
      Get.back();
      notifyListeners();
      return "Ok";
    }
    return "Please enter a vaild coupon";
  }

  discountCalculation() {
    discount = cartPrice * int.parse(coupon.data()['discount in %']) ~/ 100;
    if (discount > int.parse(coupon.data()['maxdiscount']))
      discount = int.parse(coupon.data()['maxdiscount']);
    subtotal = subtotal - discount;
  }

  Future<String> check() async {
    if (cartPrice < int.parse(coupon.data()['minamount']))
      return "Amount should be greater than ₹${coupon.data()['minamount']}";
    if (coupon.data()['For'] == "new") {
      if (phoneNo == null) {
        return "Please login before applying coupon";
      }
      DocumentSnapshot _document = await getData("users")
          .doc(phoneNo)
          .get(GetOptions(source: Source.server));

      if (_document.data()['order_count'] >
          int.parse(coupon.data()['maxorders'])) {
        return "This Coupon is only for new user";
      }
    }
    DateTime _currentDate = await NTP.now();
    DateTime _startingDate =
        DateFormat("yMMMd").parse(coupon.data()['starting Date']);
    DateTime _endingDate =
        DateFormat("yMMMd").parse(coupon.data()['ending Date']);
    _endingDate = _endingDate.add(new Duration(days: 1));
    if (_currentDate.compareTo(_startingDate) < 0) {
      return "Please enter a vaild coupon";
    }
    if (_currentDate.compareTo(_endingDate) >= 0)
      return "This coupon code is expired";
    DocumentSnapshot _document = await getData("coupons")
        .doc(coupon.id)
        .collection("redeemd")
        .doc(phoneNo)
        .get(GetOptions(source: Source.server));
    if (_document.exists) {
      if (int.parse(_document.data()['order_count'].toString()) >=
          int.parse(coupon.data()['maxorders'].toString()))
        return "Order limit exceeded";
    }
    return "ok";
  }

  couponCancel() {
    coupon = null;
    discount = 0;
    notifyListeners();
  }

  setCart() async {
    final prefs = await SharedPreferences.getInstance();
    String temp = prefs.getString('cart');
    if (temp != null) cart = new List.from(json.decode(temp));
    totalItemInCart();
  }

  CollectionReference getData(String s) {
    final _paq = databaseReference.collection(s);
    return _paq;
  }

  Future updateData(String s, String id, Map<String, dynamic> data) async {
    await databaseReference
        .collection(s)
        .doc(id)
        .update(data)
        .catchError((onError) {
      print(onError);
    });
  }

  Future<DocumentReference> createData(
      String s, Map<String, dynamic> data) async {
    return await databaseReference.collection(s).add(data);
  }

  Future transcation() async {
    await databaseReference.runTransaction((Transaction tx) async {
      print('a');
      return {'a': 'b'};
    }, timeout: const Duration(seconds: 10)).catchError((onError) {
      print(onError.toString());
    });
    print("c");
  }

  void setDataWithMerge(s, id, Map<String, dynamic> data) {
    databaseReference.collection(s).doc(id).set(data);
  }

  int findQtyInCart(String nameOfProduct, int productNo) {
    for (int i = 0; i < cart.length; i++) {
      if (cart[i]['productName'] == nameOfProduct &&
          cart[i]['productNo'] == productNo) {
        return i;
      }
    }
    return -1;
  }

  void totalItemInCart() {
    totalItemCount = 0;
    for (int i = 0; i < cart.length; i++) {
      totalItemCount = totalItemCount + cart[i]['qty'];
    }
    notifyListeners();
  }

  void addToCart(String nameOfProduct, int productNo) async {
    int index = findQtyInCart(nameOfProduct, productNo);
    if (index == -1) {
      cart.add(
          {'productName': nameOfProduct, 'productNo': productNo, 'qty': 1});
    } else {
      cart[index]['qty']++;
    }
    totalItemInCart();

    final prefs = await SharedPreferences.getInstance();

    prefs.setString('cart', json.encode(cart));
  }

  deleteCart() async {
    cart = [];
    totalItemCount = 0;
    couponCancel();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', json.encode(cart));
  }

  void removeFromCart(String nameOfProduct, int productNo,
      [bool full = true]) async {
    int index = findQtyInCart(nameOfProduct, productNo);
    if (cart[index]['qty'] == 1 || !full) {
      cart.removeAt(index);
    } else {
      cart[index]['qty']--;
    }
    totalItemInCart();
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('cart', json.encode(cart));
  }

  Future deliveryChargesCalculation() async {
    final _deliveryDcoument = await getData('delivery')
        .doc("charges")
        .get(GetOptions(source: Source.server))
        .catchError((onError) {
      return null;
    });
    if (_deliveryDcoument == null) return null;
    minAmount = int.parse(_deliveryDcoument.data()['Min Amount For Delivery']);
    print(cartPrice);
    if (cartPrice >=
        int.parse(_deliveryDcoument.data()['Min Amount For Free Delivery'])) {
      deliveryCharges = 0;
    } else {
      deliveryCharges = int.parse(_deliveryDcoument.data()['Delivery Charges']);
    }
    subtotal = cartPrice + deliveryCharges;
  }

  Future<List<DocumentSnapshot>> getCart() async {
    discount = 0;
    cartPrice = 0;
    cartMrp = 0;

    if (cart.length == 0) {
      return null;
    } else {
      List<DocumentSnapshot> _cartData = [];
      for (int i = 0; i < cart.length; i++) {
        final _temp = await getData('products')
            .doc(cart[i]['productName'])
            .get(GetOptions(source: Source.server))
            .catchError((onError) {
          return null;
        });
        if (_temp == null) break;
        if (_temp.data()['priceQty'][cart[i]['productNo']]['stock'] == 'Out') {
          cart.removeAt(i);
        } else {
          cartPrice = cartPrice +
              int.parse(
                      _temp.data()['priceQty'][cart[i]['productNo']]['price']) *
                  cart[i]['qty'];
          cartMrp = cartMrp +
              int.parse(_temp.data()['priceQty'][cart[i]['productNo']]['mrp']) *
                  cart[i]['qty'];
          _cartData.add(_temp);
        }
      }
      if (_cartData.length == 0) return null;
      await deliveryChargesCalculation();
      if (coupon != null) {
        String _mess = await check();
        if (_mess != "ok") {
          coupon = null;
          discount = 0;
        } else
          discountCalculation();
      }
      return _cartData;
    }
  }

  Future<List<QuerySnapshot>> getSubCatgories(QuerySnapshot catagories) async {
    List<QuerySnapshot> _subCatagories = [];
    for (int i = 0; i < catagories.docs.length; i++) {
      QuerySnapshot temp = await getData(catagories.docs[i].id)
          .get(GetOptions(source: Source.server))
          .catchError((onError) {
        return null;
      });
      if (temp == null) {
        return [];
      }
      _subCatagories.add(temp);
    }
    return _subCatagories;
  }
}
