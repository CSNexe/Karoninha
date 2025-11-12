import 'package:flutter/material.dart';
import 'package:karoninha/screens/login_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        )
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.deepPurple,
          secondary: Colors.amber,
      )
      ),
      home: LoginScreens(),
    );
  }
}
