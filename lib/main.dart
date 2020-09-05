import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './signup.dart';
import './homepage.dart';
import 'otp.dart';
import './backend/signin.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'user.dart';
import 'first.dart';
import 'profile.dart';
import './backend/product.dart';
import 'products.dart';
import 'cart.dart';
import 'myaddress.dart';
import 'search.dart';
import 'addressForm.dart';
import 'datetime.dart';
import 'showdate.dart';
import 'orderdetails.dart';
import 'thanku.dart';
import 'myorders.dart';
import 'productCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './backend/retry.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RemoteConfig remoteConfig = await setupRemoteConfig();
  runApp(MyApp(remoteConfig));
}

Future<RemoteConfig> setupRemoteConfig() async {
  await Firebase.initializeApp();
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  // Enable developer mode to relax fetch throttling
  remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
//  await remoteConfig.fetch(expiration: const Duration(seconds: 0));
  // await remoteConfig.activateFetched();
  return remoteConfig;
}

class MyApp extends StatelessWidget {
  RemoteConfig remoteConfig;
  MyApp([this.remoteConfig]);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Logged>(create: (context) => Logged()),
        ChangeNotifierProvider<Product>(
          create: (context) => Product(remoteConfig),
        ),
        ChangeNotifierProvider<Retry>(
          create: (context) => Retry(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Log In',
        theme: ThemeData(
            primaryColor: Color.fromRGBO(233, 98, 46, 1),
            scaffoldBackgroundColor: Colors.grey.shade200,
            accentColor: Color.fromRGBO(233, 90, 46, 1),
            cursorColor: Colors.black,
            appBarTheme: AppBarTheme(color: Color.fromRGBO(67, 72, 75, 1)),
            buttonTheme: ButtonThemeData(
              buttonColor: Color.fromRGBO(233, 98, 46, 1),
            )),
        routes: {
          '/': (BuildContext context) => First(),
          '/homepage': (BuildContext context) => homePage(),
          '/login': (BuildContext context) => signup(),
          '/otp': (BuildContext context) => Otp(),
          '/user': (BuildContext context) => User(),
          '/userProfile': (BuildContext context) => User(true),
          '/profile': (BuildContext context) => ProfilePage(),
          '/cart': (BuildContext context) => Cart(),
          '/search': (BuildContext context) => Search(),
          '/choosetime': (BuildContext context) => DateTIme(),
          '/thanku': (BuildContext context) => Thanku(),
          '/myorders': (BuildContext context) => MyOrders(),
        },
        onGenerateRoute: (settings) {
          final Map<String, dynamic> arguments = settings.arguments;
          switch (settings.name) {
            case '/products':
              if (arguments['catagory'] is String &&
                  arguments['catagory'] is String) {
                return MaterialPageRoute(
                    builder: (context) => Products(
                        arguments['catagory'], arguments['subCatagory']));
              } else {
                return null;
              }
              break;

            case '/addressForm':
              return MaterialPageRoute(
                  builder: (context) =>
                      AddressForm(arguments['data'], arguments['index']));

              break;

            case '/myaddress':
              if (arguments['checkout'] == true)
                return MaterialPageRoute(builder: (context) => MyAddress(true));
              else
                return MaterialPageRoute(
                    builder: (context) => MyAddress(false));
              break;

            case '/orderDetails':
              return MaterialPageRoute(
                  builder: (context) => OrderDetails(arguments['data']));
              break;
            case '/productCard':
              return MaterialPageRoute(
                  builder: (context) => ProductCard(
                      arguments['data'], arguments['mode'], arguments['id']));
              break;
            default:
              return null;
          }
        },
        navigatorKey: Get.key,
      ),
    );
  }
}
