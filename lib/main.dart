
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'home.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  //initialise hive
  await Hive.initFlutter();
  await Hive.openBox('My_box');
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hive',
      theme: ThemeData(
        primarySwatch: 
          Colors.cyan,

      ),
      home: const HomePage(),
    );
  }
}

