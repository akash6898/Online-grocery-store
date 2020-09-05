import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './backend/product.dart';
import 'productCard.dart';
import 'package:get/get.dart';
import './backend/signin.dart';
import 'cartButton.dart';

class Products extends StatefulWidget {
  String catagory;
  DocumentSnapshot subCatagory;

  Products([this.catagory, this.subCatagory]);
  @override
  _Products createState() {
    // TODO: implement createState
    return _Products();
  }
}

class _Products extends State<Products> {
  Stream _stream;
  Product _fireStore;
  @override
  void initState() {
    _fireStore = Provider.of<Product>(context, listen: false);
    _stream = _fireStore
        .getData('products')
        .where('catagory', isEqualTo: widget.catagory)
        .where('subCatagory', isEqualTo: widget.subCatagory.documentID)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.subCatagory.data()['name']),
          actions: <Widget>[CartButton()]),
      backgroundColor: Colors.grey.shade200,
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.documents.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return ProductCard(snapshot.data.documents[index], 0, -1);
              },
            );
          } else {
            return Center(child: Text("No Data"));
          }
        },
      ),
    );
  }
}
