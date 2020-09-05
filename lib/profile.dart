import 'package:flutter/material.dart';
import './backend/signin.dart';
import './model/profile.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() {
    return _ProfilePage();
  }
}

class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final _logged = Provider.of<Logged>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      body: Card(
        color: Colors.white,
        child: Container(
          height: 140,
          decoration:
              BoxDecoration(border: Border.all(width: 0.2, color: Colors.grey)),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'assets/dummy.png',
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      _logged.userInfo.fName + " " + _logged.userInfo.lName,
                      style: TextStyle(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      _logged.userInfo.email,
                      style: TextStyle(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      _logged.userInfo.phoneNo,
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Get.toNamed('/userProfile'))
            ],
          ),
        ),
      ),
    );
  }
}
