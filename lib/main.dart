import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HelloWorldPage(),
    );
  }
}
