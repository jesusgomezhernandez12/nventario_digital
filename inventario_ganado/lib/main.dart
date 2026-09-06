import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const InventarioGanadoApp());
}

class InventarioGanadoApp extends StatelessWidget {
  const InventarioGanadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Ganadero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, // Color muy ganadero
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}