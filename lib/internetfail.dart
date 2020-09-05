import 'package:flutter/material.dart';
import './backend/retry.dart';
import 'package:provider/provider.dart';

class InternetFail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _retry = Provider.of<Retry>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "No internet connection",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Ugh! Something's not right with your internet",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        SizedBox(
          height: 10,
        ),
        RaisedButton(
          onPressed: () {
            _retry.retry();
          },
          child: Text(
            "Try Again",
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
          elevation: 0,
        )
      ],
    );
  }
}
