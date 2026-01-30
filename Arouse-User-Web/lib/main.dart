import 'package:arouse_ecommerce_frontend_web/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arouse',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
