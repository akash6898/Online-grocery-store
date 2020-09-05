import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import './backend/signin.dart';
import 'homepage.dart';

class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _logged = Provider.of<Logged>(context, listen: false);
    // TODO: implement build
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _logged.signedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return homePage();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
