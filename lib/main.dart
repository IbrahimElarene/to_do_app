import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/sql_helper.dart';

import 'notes&todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqlHelper().getDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GDSC Benha',
      home: NotesTodo(),
    );
  }
}
