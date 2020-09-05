import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  String _message;
  Loading(this._message);
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      title: Container(
        width: 100,
        height: 70,
        padding: EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 10,
            ),
            Center(
              child: Container(
                width: 40,
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                _message,
                maxLines: 2,
                softWrap: true,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
