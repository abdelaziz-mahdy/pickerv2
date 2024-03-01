import 'package:flutter/material.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChoicesOperation>(
      create: (context) => ChoicesOperation(),
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
