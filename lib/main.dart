import 'package:flutter/material.dart';
import 'package:pickerv2/models/Choicesoperation.dart';
import 'package:pickerv2/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChoicesOperation>(
      create: (context)=> ChoicesOperation(),
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        home:new HomeScreen(),
      ),
    );
  }
}
