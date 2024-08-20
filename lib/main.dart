import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'temperature_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginScreen(), // Giriş ekranını başlangıç ekranı olarak ayarlıyoruz
      debugShowCheckedModeBanner: false,
    );
  }
}
