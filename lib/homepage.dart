import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmart/internetfail.dart';
import 'package:share/share.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'backend/product.dart';
import 'catagoryCard.dart';
import 'productCard.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'cartButton.dart';
import './backend/retry.dart';
import 'package:url_launcher/url_launcher.dart';

class homePage extends StatefulWidget {
  @override
  _homePage createState() {
    return _homePage();
  }
}

class _homePage extends State<homePage> {
  Future _cat, _subCat;
  double _height, _width;
  int _selectedIndex = -1;
  Product _product;
  Logged _logged;
  String url = "tel:";
  String url1 = "mailto:";
  @override
  Widget build(BuildContext context) {
    _product = Provider.of<Product>(context, listen: false);
    _logged = Provider.of<Logged>(context, listen: false);
    final _retry = Provider.of<Retry>(context);
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Gmart"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Get.toNamed("/search");
              }),
          CartButton(),
        ],
      ),
      drawer: _drawer(_logged),
      body: showCatagory(),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _drawer(Logged _logged) {
    return SafeArea(
      child: Container(
        width: _width * .7,
        height: _height,
        color: Colors.grey.shade200,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                  child: Align(
                    child: _logged.isLoggedIn
                        ? Text(
                            "Hello, " + _logged.userInfo.fName,
                            style: TextStyle(fontSize: 18),
                          )
                        : Text("Welcome"),
                    alignment: Alignment.centerLeft,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
                color: Colors.grey.shade400,
                width: double.infinity,
                height: 50,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      child: Row(children: <Widget>[
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 20,
                        ),
                        _logged.isLoggedIn
                            ? Text(
                                "Logout",
                                style: TextStyle(fontWeight: FontWeight.normal),
                              )
                            : Text(
                                "Login",
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                      ]),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  onPressed: () {
                    if (_logged.isLoggedIn) {
                      _logged.logout();
                    } else {
                      Get.back();
                      Get.toNamed('/login');
                    }
                  },
                ),
              ),
              _menuButtons("My Cart", null, Icons.shopping_cart, '/cart'),
              _menuButtons("My Profile", null, Icons.person, '/profile'),
              _menuButtons('My Addresses', null, Icons.location_on,
                  '/myaddress', {'checkout': false}),
              _menuButtons('My Orders', null, Icons.assessment, '/myorders'),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Others",
                          style: TextStyle(color: Colors.grey.shade700)))),
              SizedBox(
                height: 5,
              ),
              _menuButtons(
                'Call Us',
                _makePhoneCall,
                Icons.phone,
              ),
              _menuButtons(
                'Email Us',
                _Email,
                Icons.email,
              ),
              _menuButtons("Rate Us", null, Icons.star_border, '/'),
              _menuButtons('share App', share, Icons.share),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButtons(String name, Function _function,
      [IconData iconName, String path, Map<String, dynamic> arguments]) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              iconName != null
                  ? Icon(
                      iconName,
                    )
                  : SizedBox(),
              iconName != null
                  ? SizedBox(
                      width: 20,
                    )
                  : SizedBox(),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        onPressed: _function != null
            ? () async {
                Get.back();
                await _function();
              }
            : () {
                Get.back();
                if (path == "/profile" ||
                    path == "/myaddress" ||
                    path == "/myorders") {
                  _logged.isLoggedIn
                      ? Get.toNamed(path, arguments: arguments)
                      : Get.toNamed('/login');
                } else
                  Get.toNamed(path, arguments: arguments);
              },
      ),
    );
  }

  void share() {
    final RenderBox box = context.findRenderObject();
    Share.share("hello",
        subject: "hello",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Future<void> _makePhoneCall() async {
    url = url + _product.call;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _Email() async {
    url1 = url1 + _product.email;
    if (await canLaunch(url1)) {
      await launch(url1);
    } else {
      throw 'Could not launch $url1';
    }
  }

  Widget showCatagory() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data['query1'] != null &&
              snapshot.data['query2'] != null &&
              snapshot.data['query3'] != null &&
              snapshot.data['query4'] != null) {
            return CatogaryList(snapshot.data);
          } else {
            return Center(
              child: InternetFail(),
            );
          }
        }
      },
    );
  }

  Future<Map<String, dynamic>> _futureList() async {
    Map<String, dynamic> _snapshot = {
      'query1': null,
      'query2': null,
      'query3': null,
      'query4': null
    };
    QuerySnapshot _query1 = await _product
        .getData("catagory")
        .get(GetOptions(source: Source.server))
        .catchError((onError) {
      return null;
    });
    if (_query1 == null) return _snapshot;
    if (_query1.docs.length == 0) {
      _snapshot['query1'] = null;
      return _snapshot;
    } else {
      _snapshot['query1'] = _query1;
    }
    List<QuerySnapshot> _query2 = await _product.getSubCatgories(_query1);
    if (_query2.length == 0) {
      _snapshot['query2'] = null;
      return _snapshot;
    } else {
      _snapshot['query2'] = _query2;
    }
    QuerySnapshot _query3 = await _product
        .getData("products")
        .where("isFeatured", isEqualTo: true)
        .get(GetOptions(source: Source.server))
        .catchError((onError) {
      return null;
    });
    if (_query3 == null) return _snapshot;
    if (_query3.docs.length == 0) {
      _snapshot['query3'] = null;
      return _snapshot;
    } else {
      _snapshot['query3'] = _query3;
    }
    QuerySnapshot _query4 = await _product
        .getData("imageSlider")
        .get(GetOptions(source: Source.server))
        .catchError((onError) {
      return null;
    });
    if (_query4 == null) return _snapshot;
    if (_query4.docs.length == 0) {
      _snapshot['query4'] = null;
      return _snapshot;
    } else {
      _snapshot['query4'] = _query4;
    }
    return _snapshot;
  }

  @override
  void initState() {
    // _cat = _product.getData("catagory").getDocuments();

    super.initState();
  }
}

class CatogaryList extends StatefulWidget {
  Map<String, dynamic> _data;
  CatogaryList(this._data);

  @override
  _CatogaryListState createState() => _CatogaryListState();
}

class _CatogaryListState extends State<CatogaryList> {
  QuerySnapshot q1, q3, q4;
  List<QuerySnapshot> q2;
  @override
  void initState() {
    q1 = widget._data['query1'];
    q2 = widget._data['query2'];
    q3 = widget._data['query3'];
    q4 = widget._data['query4'];
    super.initState();
  }

  int id = -1;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: q1.docs.length + 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CarouselSlider.builder(
            options: CarouselOptions(height: 200.0, autoPlay: true),
            itemCount: q4.docs.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.amber,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Image.network(
                  q4.docs[index].data()['url'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              );
            },
          );
        } else if (index == 1) {
          return SizedBox(
            height: 10,
          );
        } else if (index == 2) {
          return Container(
            height: 260,
            padding: EdgeInsets.all(10),
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "BEST OF EVERYDAY ESSENTIALS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    height: 200,
                    child: ListView.builder(
                      itemBuilder: (context, index1) {
                        return ProductCard(q3.docs[index1], 2);
                      },
                      itemCount: q3.docs.length,
                      scrollDirection: Axis.horizontal,
                    )),
              ],
            ),
          );
        } else if (index == 3) {
          return SizedBox(
            height: 10,
          );
        } else
          return Column(
            children: <Widget>[
              GestureDetector(
                child: CatagoryCard(q1.docs[index - 4], q2[index - 4],
                    id == index - 4 ? true : false),
                onTap: () {
                  if (id == index - 4) {
                    setState(() {
                      id = -1;
                    });
                  } else {
                    setState(() {
                      id = index - 4;
                    });
                  }
                },
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
      },
    );
  }
}
