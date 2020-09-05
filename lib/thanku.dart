import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Thanku extends StatefulWidget {
  @override
  _ThankuState createState() => _ThankuState();
}

class _ThankuState extends State<Thanku> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.offAllNamed('/homepage');
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Thank you'),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            height: 250,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.2, color: Colors.grey)),
            child: Column(
              children: <Widget>[
                Container(
                  height: 100,
                  child: FlareActor(
                    "assets/sucess.flr",
                    animation: "Untitled",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Yay! Order Successfully Placed",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  elevation: 0,
                  child: Text(
                    "Continue Shopping",
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  onPressed: () => Get.offAllNamed('/homepage'),
                ),
                /* FlatButton(
                    onPressed: () => Get.offAllNamed('/myorders'),
                    child: Text(
                      "Go To My Orders",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor),
                    ))*/
              ],
            ),
          )),
    );
  }
}
