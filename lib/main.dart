import 'package:flutter/material.dart';
import 'package:recipe_finder/SearchRecipeWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchRecipeWidget(),
    );
  }
}
