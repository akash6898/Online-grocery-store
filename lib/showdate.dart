import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowDate extends StatelessWidget {
  List<String> _dates;
  int _index;
  bool _isDate;
  ShowDate(this._dates, this._index, this._isDate);
  int _radioValue;
  @override
  Widget build(BuildContext context) {
    _radioValue = _index;
    List<Widget> _widgetList = [];
    for (int i = 0; i < _dates.length; i++) {
      _widgetList.add(radio(_dates[i], i));
    }
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: _isDate ? Text("choose date") : Text("choose time"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _widgetList,
        ));
  }

  Widget radio(String title, int i) {
    return ListTile(
      leading: Radio(
        value: i,
        groupValue: _radioValue,
      ),
      title: Text(title),
      onTap: () {
        Get.back(result: i);
      },
    );
  }
}
