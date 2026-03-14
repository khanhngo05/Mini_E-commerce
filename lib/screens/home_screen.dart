import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TH4 - Nhom [So nhom]')),
      body: const Center(child: Text('Mini E-Commerce - Commit 1 setup')),
    );
  }
}
