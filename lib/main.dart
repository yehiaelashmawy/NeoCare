import 'package:flutter/material.dart';

void main() {
  runApp(const NeoCareApp());
}

class NeoCareApp extends StatelessWidget {
  const NeoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Column()),
    );
  }
}
