import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gmart/internetfail.dart';
import 'package:gmart/loading.dart';
import 'package:provider/provider.dart';
import './model/profile.dart';
import './backend/product.dart';
import './backend/signin.dart';
import 'productCard.dart';
import 'backend/subtotal.dart';
import 'package:get/get.dart';
import './backend/retry.dart';

class Cart extends StatefulWidget {
  @override
  _Cart createState() {
    // TODO: implement createState
    return _Cart();
  }
}

class _Cart extends State<Cart> {
  Product _product;
  Logged _logged;
  bool _click = false;
  Subtotal _cartPrice = Subtotal();
  void dispose() {
    super.dispose();
    _cartPrice.dispose();
  }

  TextEditingController _code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _product = Provider.of<Product>(context);
    _logged = Provider.of<Logged>(context);
    final _retry = Provider.of<Retry>(context);
    _click = false;
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Cart"),
        ),
        backgroundColor: Colors.grey.shade200,
        body: FutureBuilder<List<DocumentSnapshot>>(
          future: _product.getCart(),
          builder: (context, snapshot) {
            _product.item = new Set();
            _product.phoneNo = _logged.phoneNo;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      _cartPrice.incSink.add(_product.subtotal);
                      _click = true;
                      return Padding(
                        padding: EdgeInsets.all(3),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("M.R.P."),
                                    Text("₹" + _product.cartMrp.toString()),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Products Discount"),
                                    Text(
                                      "- ₹" +
                                          (_product.cartMrp -
                                                  _product.cartPrice)
                                              .toString(),
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(93, 170, 29, 1)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Coupon"),
                                    Expanded(
                                        child: SizedBox(
                                      width: 0,
                                    )),
                                    _product.coupon == null
                                        ? SizedBox(
                                            width: 0,
                                          )
                                        : Text(
                                            _product.coupon.data()['name'],
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    93, 170, 29, 1)),
                                          ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    _product.coupon == null
                                        ? GestureDetector(
                                            onTap: () async {
                                              _code.clear();
                                              await Get.dialog(AlertDialog(
                                                content: TextField(
                                                  controller: _code,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      labelText:
                                                          "Enter The Code"),
                                                ),
                                                actionsPadding:
                                                    EdgeInsets.all(5),
                                                actions: <Widget>[
                                                  GestureDetector(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        "APPLY",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        _code.clear();
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        "CANCEL",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ))
                                                ],
                                              ));
                                              if (_code.text.length > 0) {
                                                Get.dialog(Loading("Loading"),
                                                    barrierDismissible: false);

                                                String _message = await _product
                                                    .getCoupon(_code.text);

                                                if (_message != "Ok") {
                                                  Get.back();
                                                  Get.dialog(AlertDialog(
                                                    actionsPadding:
                                                        EdgeInsets.all(5),
                                                    content: Text(_message),
                                                    actions: <Widget>[
                                                      GestureDetector(
                                                          onTap: () {
                                                            Get.back();
                                                          },
                                                          child: Text(
                                                            "OK",
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                          ))
                                                    ],
                                                  ));
                                                }
                                              }
                                            },
                                            child: Text(
                                              "Apply Coupon",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      93, 170, 29, 1)),
                                            ),
                                          )
                                        : GestureDetector(
                                            child: Icon(
                                              Icons.cancel,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onTap: () {
                                              _product.couponCancel();
                                            },
                                          )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _product.discount != 0
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("Products Discount"),
                                          Text(
                                            "- ₹" +
                                                _product.discount.toString(),
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    93, 170, 29, 1)),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                SizedBox(
                                  height: _product.discount != 0 ? 10 : 0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Delivery Charges"),
                                    _product.deliveryCharges != 0
                                        ? Text("₹" +
                                            _product.deliveryCharges.toString())
                                        : Text(
                                            "FREE",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    93, 170, 29, 1)),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Sub total",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "₹" + (_product.subtotal).toString(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () => Get.toNamed('/productCard', arguments: {
                          'data': snapshot.data[index - 1],
                          'mode': 1,
                          'id': _product.cart[index - 1]['productNo']
                        }),
                        child: ProductCard(snapshot.data[index - 1], 0,
                            _product.cart[index - 1]['productNo']),
                      );
                    }
                  });
            } else {
              _cartPrice.incSink.add(-1);
              if (_product.totalItemCount != 0) {
                return Center(child: InternetFail());
              } else
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No items in your cart",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Your favourite items are just a click away",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Get.offAllNamed('/homepage');
                      },
                      elevation: 0,
                      child: Text(
                        "Start Shopping",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ));
            }
          },
        ),
        bottomNavigationBar: StreamBuilder<int>(
            stream: _cartPrice.counterStream,
            builder: (context, snapshot) {
              return snapshot.data == -1
                  ? SizedBox()
                  : RaisedButton(
                      padding: EdgeInsets.all(0),
                      elevation: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              _logged.isLoggedIn
                                  ? "Checkout"
                                  : "Login To Checkout",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                            Expanded(
                                child: SizedBox(
                              width: 1,
                            )),
                            Text(
                              '₹${snapshot.data.toString()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      onPressed: !_click
                          ? null
                          : () {
                              _product.subtotal = snapshot.data;
                              if (_product.minAmount > _product.cartPrice) {
                                Get.dialog(AlertDialog(
                                  content: Text(
                                      "Minimum Amount should be greater than ₹${_product.minAmount}"),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ));
                              } else {
                                _logged.isLoggedIn
                                    ? Get.toNamed('/myaddress', arguments: {
                                        'checkout': true,
                                      })
                                    : Get.toNamed('/login');
                              }
                            },
                    );
            }));
  }
}
