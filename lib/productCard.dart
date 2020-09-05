import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './backend/product.dart';
import 'package:get/get.dart';
import './backend/signin.dart';
import './backend/product.dart';
import 'cartButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './backend/retry.dart';

class ProductCard extends StatefulWidget {
  DocumentSnapshot _data;
  int _productNo;
  int mode;

  ProductCard(this._data, this.mode, [this._productNo = -1]);

  @override
  _ProductPage createState() {
    // TODO: implement createState
    return _ProductPage();
  }
}

class _ProductPage extends State<ProductCard> {
  int _selectedQty = 0;
  Product _product;
  Map<String, dynamic> _itemData = {};

  @override
  void initState() {
    final _productFinal = Provider.of<Product>(context, listen: false);

    if (widget._productNo != -1) {
      _selectedQty = widget._productNo;
    } else {
      for (int i = 0; i < widget._data.data()['priceQty'].length; i++) {
        if (_productFinal.findQtyInCart(widget._data.id, i) != -1) {
          _selectedQty = i;

          break;
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _product = Provider.of<Product>(context);
    _itemData['product'] = widget._data.id;
    _itemData['unit'] = widget._data.data()['priceQty'][_selectedQty]['qty'];
    _itemData['mrp'] = widget._data.data()['priceQty'][_selectedQty]['mrp'];
    _itemData['price'] = widget._data.data()['priceQty'][_selectedQty]['price'];
    _itemData['productName'] = widget._data.data()['name'];
    if (_product.cart.length != 0 &&
        _product.findQtyInCart(widget._data.id, _selectedQty) != -1 &&
        widget._data.data()['priceQty'][_selectedQty]['stock'] != "Out") {
      _itemData['quantity'] = _product
          .cart[_product.findQtyInCart(widget._data.id, _selectedQty)]['qty'];
      _product.item.add(_itemData);
    }
    double discount;
    discount =
        ((int.parse(widget._data.data()['priceQty'][_selectedQty]['mrp']) -
                    int.parse(widget._data.data()['priceQty'][_selectedQty]
                        ['price'])) *
                100) /
            int.parse(widget._data.data()['priceQty'][_selectedQty]['mrp']);
    if (widget.mode == 0) return listCard(discount, context);
    if (widget.mode == 1) return detailCard(discount, context);
    if (widget.mode == 2) return featuredCard(discount, context);
  }

  Widget featuredCard(double discount, context) {
    print(widget._data.data()['priceQty']);
    return GestureDetector(
      onTap: () => Get.toNamed('/productCard', arguments: {
        'data': widget._data,
        'mode': 1,
        'id': _selectedQty,
      }),
      child: Container(
        width: 200,
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget._data.data()["url"],
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) {
                      return Icon(Icons.error);
                    },
                    height: 100,
                    width: 90,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "₹${widget._data.data()['priceQty'][_selectedQty]['price']}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "₹${widget._data.data()['priceQty'][_selectedQty]['mrp']}",
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(decoration: TextDecoration.lineThrough),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Text(
                          "${discount.toInt()}% off",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromRGBO(93, 170, 29, 1)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget._data.data()['name'],
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
            SizedBox(
              height: 5,
            ),
            Text(widget._data.data()['priceQty'][0]['qty']),
            SizedBox(
              height: 5,
            ),
            addButon(widget._data, 174)
          ],
        ),
      ),
    );
  }

  Scaffold detailCard(double discount, BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[CartButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: widget._data.data()["url"],
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) {
                return Icon(Icons.error);
              },
              height: 225,
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Text(
                      discount.toInt().toString() + "% off",
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromRGBO(93, 170, 29, 1)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget._data.data()['name'],
                    style: TextStyle(fontSize: 18),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Product MRP: ",
                          style: TextStyle(
                            fontSize: 18,
                          )),
                      Text(
                        "₹${widget._data.data()['priceQty'][_selectedQty]['mrp']}",
                        style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text("Selling Price: ",
                                    style: TextStyle(
                                      fontSize: 18,
                                    )),
                                Text(
                                  "₹${widget._data.data()['priceQty'][_selectedQty]['price']}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                          SizedBox(
                            height: 10,
                          ),
                          Text("(Inclusive of all taxes)")
                        ],
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 1,
                        ),
                      ),
                      addButon(widget._data, 90)
                    ],
                  ),
                  Divider(
                    height: 30,
                    thickness: 1,
                  ),
                  Text(
                    "Unit",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: unit(),
                    height: 30,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(widget._data.data()['description'])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget listCard(double discount, BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/productCard', arguments: {
        'data': widget._data,
        'mode': 1,
        'id': _selectedQty,
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Card(
          elevation: 1,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            height: 120,
            padding: EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget._data.data()["url"],
                  placeholder: (context, url) => Container(),
                  errorWidget: (context, url, error) {
                    return Icon(Icons.error);
                  },
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "₹${widget._data.data()['priceQty'][_selectedQty]['price']}",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "₹${widget._data.data()['priceQty'][_selectedQty]['mrp']}",
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              child: Text(
                                discount.toInt().toString() + "% off",
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color.fromRGBO(93, 170, 29, 1)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget._data.data()['name'],
                        style: TextStyle(fontSize: 18),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            if (widget._data.data()['priceQty'].length == 1 ||
                                widget._productNo != -1)
                              Text(widget._data.data()['priceQty'][_selectedQty]
                                  ['qty'])
                            else
                              GestureDetector(
                                child: Container(
                                  height: double.infinity,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                        width: 0.8,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          widget._data.data()['priceQty']
                                              [_selectedQty]['qty'],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Icon(Icons.keyboard_arrow_down,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  getQty();
                                },
                              ),
                            Expanded(
                              child: SizedBox(width: 1),
                            ),
                            widget._productNo != -1
                                ? IconButton(
                                    color: Theme.of(context).primaryColor,
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _product.removeFromCart(
                                          widget._data.id, _selectedQty, false);
                                    })
                                : SizedBox(
                                    width: 0,
                                  ),
                            addButon(widget._data, 90)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addButon(DocumentSnapshot _document, double _width) {
    if (_document.data()['priceQty'][_selectedQty]['stock'] == 'Out') {
      if (_product.findQtyInCart(widget._data.id, _selectedQty) != -1)
        _product.removeFromCart(widget._data.id, _selectedQty, false);
      return Container(
        width: _width,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).primaryColor)),
        child: Center(
          child: Text(
            "Out Of Stock",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      );
    }
    return Container(
      width: _width,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: _product.findQtyInCart(widget._data.id, _selectedQty) == -1
          ? RaisedButton(
              elevation: 0,
              onPressed: () =>
                  _product.addToCart(widget._data.id, _selectedQty),
              padding: EdgeInsets.all(0),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5))),
                        child: Center(
                          child: Text(
                            "ADD",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                  ),
                  Container(
                      width: 30,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(191, 83, 38, 1),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5))),
                      child: Center(
                        child: Text(
                          "+",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ))
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: RaisedButton(
                    elevation: 0,
                    onPressed: () =>
                        _product.removeFromCart(widget._data.id, _selectedQty),
                    child: Text(
                      "-",
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: Text(_product.cart[_product.findQtyInCart(
                              widget._data.id, _selectedQty)]['qty']
                          .toString()),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: RaisedButton(
                    elevation: 0,
                    onPressed: () =>
                        _product.addToCart(widget._data.id, _selectedQty),
                    child: Text(
                      "+",
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
    );
  }

  void getQty() {
    List<Widget> _widget = [];
    List<dynamic> _qtyData = widget._data.data()['priceQty'];
    for (int i = 0; i < _qtyData.length; i++) {
      // print(_qtyData[i]);
      _widget.add(Divider(
        height: 1,
      ));
      _widget.add(Padding(
        padding: EdgeInsets.all(5),
        child: FlatButton(
          child: RichText(
            text: TextSpan(style: TextStyle(fontSize: 16), children: [
              TextSpan(
                  text: "${_qtyData[i]['qty']} - ",
                  style: TextStyle(
                      color: _selectedQty == i ? Colors.white : Colors.black)),
              TextSpan(
                  text: "₹${_qtyData[i]['mrp']}",
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: _selectedQty == i
                          ? Colors.white
                          : Colors.grey.shade700)),
              TextSpan(
                  text: "  ₹${_qtyData[i]['price']}",
                  style: TextStyle(
                      color: _selectedQty == i ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold))
            ]),
          ),
          color: _selectedQty == i ? Colors.red : Colors.white,
          onPressed: () {
            setState(() {
              _selectedQty = i;
              Get.back();
            });
          },
        ),
      ));
    }
    Get.dialog(SimpleDialog(
        titlePadding: EdgeInsets.all(8),
        contentPadding: EdgeInsets.all(5),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Available quantities for",
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.normal,
                  fontSize: 15),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget._data.data()['name'],
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ],
        ),
        children: _widget));
  }

  Widget unit() {
    List<Widget> _widget = [];
    List<dynamic> _qtyData = widget._data.data()['priceQty'];
    for (int i = 0; i < _qtyData.length; i++) {
      _widget.add(
        OutlineButton(
          highlightedBorderColor: Theme.of(context).backgroundColor,
          child: Text(_qtyData[i]['qty']),
          borderSide: BorderSide(
            color: _selectedQty == i
                ? Theme.of(context).accentColor
                : Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () {
            setState(() {
              _selectedQty = i;
            });
          },
        ),
      );
      _widget.add(SizedBox(
        width: 10,
      ));
    }
    return ListView(
      scrollDirection: Axis.horizontal,
      children: _widget,
    );
  }
}
