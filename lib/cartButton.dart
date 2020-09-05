import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'backend/product.dart';
import 'package:get/get.dart';

class CartButton extends StatefulWidget {
  CartButton({Key key}) : super(key: key);

  @override
  _CartButtonState createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  @override
  Widget build(BuildContext context) {
    Product _product = Provider.of<Product>(context);
    return Container(
        child: Badge(
      badgeColor: Theme.of(context).primaryColor,
      showBadge: _product.totalItemCount == 0 ? false : true,
      badgeContent: Text(
        _product.totalItemCount.toString(),
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
      alignment: Alignment.center,
      position: BadgePosition.topRight(top: 2, right: 2),
      child: IconButton(
          padding: EdgeInsets.all(5),
          icon: Icon(Icons.shopping_cart),
          onPressed: () => Get.toNamed("/cart")),
    ));
  }
}
