import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './backend/product.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class CatagoryCard extends StatefulWidget {
  DocumentSnapshot _data;
  QuerySnapshot _subCatagories;
  bool isSelected;
  CatagoryCard(this._data, this._subCatagories, this.isSelected);

  @override
  _CatagoryCard createState() {
    // TODO: implement createState
    return _CatagoryCard();
  }
}

class _CatagoryCard extends State<CatagoryCard> with TickerProviderStateMixin {
  DocumentSnapshot _data;
  bool _isSelected;
  double _height = 0;
  Animation _arrowAnimation;
  AnimationController _arrowAnimationController;

  @override
  void initState() {
    super.initState();
    _arrowAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _arrowAnimation =
        Tween(begin: 0.0, end: pi).animate(_arrowAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    _isSelected = widget.isSelected;
    _data = widget._data;
    Product _product = Provider.of<Product>(context, listen: false);
    String text = '';
    for (int i = 0; i < widget._subCatagories.docs.length; i++) {
      text = text + widget._subCatagories.docs[i].data()['name'];
      if (i != widget._subCatagories.docs.length - 1) text = text + ",";
    }
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: _isSelected == true ? Colors.yellow.shade200 : Colors.white,
          border: Border.symmetric(vertical: BorderSide(width: 0.1))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: _data.data()["url"],
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: 130,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      verticalDirection: VerticalDirection.up,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          _data.data()['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Transform.rotate(
                      angle: _isSelected ? 0 : pi,
                      child: Icon(
                        Icons.expand_more,
                      ),
                    ),
                  )
                ],
              ),
            ),
            _isSelected
                ? SizedBox(
                    height: 20,
                  )
                : SizedBox(),
            _isSelected
                ? Builder(builder: (context) {
                    List<TableRow> _list = [];
                    for (int i = 0;
                        i < widget._subCatagories.docs.length;
                        i = i + 3) {
                      _list.add(TableRow(children: [
                        showTableData(widget._subCatagories.docs[i]),
                        i + 1 < widget._subCatagories.docs.length
                            ? showTableData(widget._subCatagories.docs[i + 1])
                            : SizedBox(),
                        i + 2 < widget._subCatagories.docs.length
                            ? showTableData(widget._subCatagories.docs[i + 2])
                            : SizedBox(),
                      ]));
                    }
                    return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Table(
                          columnWidths: {
                            0: FractionColumnWidth(1 / 3),
                            1: FractionColumnWidth(1 / 3),
                            2: FractionColumnWidth(1 / 3),
                          },
                          border: TableBorder(
                              verticalInside: BorderSide(width: 0.1),
                              horizontalInside: BorderSide(width: 0.1)),
                          children: _list,
                        ));
                  })
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget showTableData(DocumentSnapshot tableData) {
    return FlatButton(
      onPressed: () {
        Get.toNamed('/products',
            arguments: {'catagory': _data.id, 'subCatagory': tableData});
      },
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: tableData.data()['url'],
            placeholder: (context, url) => Container(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: 50,
            height: 70,
            fit: BoxFit.fill,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            tableData.data()['name'],
            style: TextStyle(fontWeight: FontWeight.normal),
            maxLines: 2,
            softWrap: true,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
