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

          theme:ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.blue[900],
            backgroundColor: Colors.white,
            selectedRowColor: Colors.grey,
            // Define the default font family.
            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.

          ),
        home:HomeScreen(),
      ),
    );
  }
}
