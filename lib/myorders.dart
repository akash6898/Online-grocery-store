import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gmart/internetfail.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './backend/product.dart';
import './backend/signin.dart';
import './trackbar.dart';
import './backend/retry.dart';

class MyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _logged = Provider.of<Logged>(context, listen: false);
    final _retry = Provider.of<Retry>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("My orders"),
        ),
        backgroundColor: Colors.grey.shade200,
        body: FutureBuilder<DocumentSnapshot>(
          future: _product
              .getData("users")
              .doc(_logged.user.phoneNumber.substring(3))
              .get(GetOptions(source: Source.server)),
          builder: (context, snapshot1) {
            if (snapshot1.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot1.hasError) {
              return Center(child: InternetFail());
            }
            if (snapshot1.data.data()['order_count'] == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You have no past orders",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Let's get you started",
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
                    )
                  ],
                ),
              );
            } else
              return StreamBuilder<QuerySnapshot>(
                stream: _product
                    .getData("orders")
                    .orderBy("ordered on", descending: true)
                    .where('user',
                        isEqualTo: _logged.user.phoneNumber.substring(3))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    print("err");
                    print(snapshot.error);
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text("No data"),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            Timestamp t =
                                snapshot.data.docs[index].data()['ordered on'];
                            var date = new DateTime.fromMicrosecondsSinceEpoch(
                                t.microsecondsSinceEpoch);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  height: 40,
                                  padding: EdgeInsets.all(5),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      "Placed On ${DateFormat('yMMMd').format(date)} ${DateFormat('jm').format(date)}",
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.2),
                                        color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Center(
                                            child: Text(
                                                'Scheduled On ${snapshot.data.docs[index].data()['delivery date']},${snapshot.data.docs[index].data()['delivery time']}')),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.grey)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Image.network(
                                                    "https://cdn2.iconfinder.com/data/icons/real-estate-1-12/50/13-512.png",
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.fill,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text("Order no"),
                                                            Text(snapshot.data
                                                                .docs[index].id)
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                                "Delivery charges"),
                                                            int.parse(snapshot
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .data()['delivery charges']) ==
                                                                    0
                                                                ? Text(
                                                                    "FREE",
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            93,
                                                                            170,
                                                                            29,
                                                                            1)),
                                                                  )
                                                                : Text(
                                                                    "₹" +
                                                                        snapshot
                                                                            .data
                                                                            .docs[index]
                                                                            .data()['delivery charges'],
                                                                  )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              snapshot.data.docs[index]
                                                          .data()['status'] !=
                                                      "Canceled"
                                                  ? TrackBar(snapshot
                                                      .data.docs[index]
                                                      .data()['status'])
                                                  : Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.cancel,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "Canceled",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        )
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "Total Amount",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  "₹" +
                                                      snapshot.data.docs[index]
                                                          .data()['subtotal']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        RaisedButton(
                                          elevation: 0,
                                          child: Text(
                                            "View Order Details",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {
                                            Get.toNamed('/orderDetails',
                                                arguments: {
                                                  'data': snapshot
                                                      .data.docs[index].id
                                                });
                                          },
                                        )
                                      ],
                                    ))
                              ],
                            );
                          });
                    }
                  }
                },
              );
          },
        ));
  }
}
