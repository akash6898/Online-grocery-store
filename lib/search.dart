import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './backend/product.dart';
import 'productCard.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Search extends StatefulWidget {
  @override
  _Search createState() {
    // TODO: implement createState
    return _Search();
  }
}

class _Search extends State<Search> {
  TextEditingController _searchController = new TextEditingController();
  String _SerachedText = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    print(MediaQuery.of(context).size.width);
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (text) {
              setState(() {
                _SerachedText = text;
              });
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                hintText: "🔎 Search Products"),
          ),
        ),
        body: null);
  }
}
