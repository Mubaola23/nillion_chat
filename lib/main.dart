import 'package:flutter/material.dart';
import 'package:nillion_chat/view/nillion_thread_app_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nillion Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NillionThreadAppView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
