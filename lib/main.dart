import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tasks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasks',
      home: TaskListScreen(title: 'Task Bar App'),
    );
  }
}
