import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RecipeWeb extends StatelessWidget {
  static String tag = 'recipe-web';
  final String url;
  final String item;

  RecipeWeb({Key? key, required this.url, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe for $item"),
      ),
      body: MaterialApp(
        routes: {
          "/": (_) => WebviewScaffold(
                url: url,
                appBar: AppBar(
                  title: Text("Recipe"),
                ),
              )
        },
      ),
    );
  }
}
