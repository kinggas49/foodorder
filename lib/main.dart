import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'menu.dart';
import 'order_summary.dart';
import 'order_page.dart';
import 'admin_order_page.dart';
import 'cart_model.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ?
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyA5mPVdwkiTfZbkczGyTRbk7ANvXgVvlQQ",
      appId: "1:633633547331:android:c04690679e207125f060f6",
      messagingSenderId: "633633547331",
      projectId: "order-food-5da95",
    ),
  ):Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kelawai',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/menu': (context) => MenuPage(),
          '/order_summary': (context) => OrderSummaryPage(),
          '/order_page': (context) => OrderPage(),
          '/admin_order_page': (context) => AdminOrderPage(),
        },
      ),
    );
  }
}
