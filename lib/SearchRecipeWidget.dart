import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'RecipeWeb.dart';

class SearchRecipeWidget extends StatefulWidget {
  static String tag = 'recipe-page';

  @override
  _SearchRecipeWidgetState createState() => _SearchRecipeWidgetState();
}

class _SearchRecipeWidgetState extends State<SearchRecipeWidget> {
  List<Recipe> _items = [];
  final subject = PublishSubject<String>();
  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController();

  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _clearList();

    final appId = 'YOUR_EDAMAM_APP_ID';
    final appKey = 'YOUR_EDAMAM_APP_KEY';
    final apiUrl =
        'https://api.edamam.com/search?q=$text&app_id=b86e545e&app_key=56cc53ab7f3161ed5ad280ded9cc61ca';

    http
        .get(Uri.parse(apiUrl))
        .then((response) {
          if (response.statusCode == 200) {
            return response.body;
          } else {
            throw Exception('Failed to load recipes');
          }
        })
        .then(json.decode)
        .then((map) {
          final List<dynamic> hits = map["hits"];

          hits.forEach((hit) {
            final recipe = hit["recipe"];
            _addItem({
              "title": recipe["label"],
              "ingredients": recipe["ingredientLines"].join(', '),
              "thumbnail": recipe["image"],
              "href": recipe["url"],
            });
          });
        })
        .catchError((error) {
          print('API Error: $error');
          // Display an error message to the user
          // You can show an error message in your UI here
        })
        .then((e) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _addItem(item) {
    setState(() {
      _items.add(Recipe.fromJson(item));
    });
  }

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounceTime(Duration(milliseconds: 600))
        .listen(_textChanged);
  }

  Widget _createSearchBar(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: clearData,
          ),
          Expanded(
            child: TextField(
              autofocus: true,
              controller: textEditingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.0),
                hintText: 'Search Recipes here',
              ),
              onChanged: (string) => subject.add(string),
            ),
          ),
        ],
      ),
    );
  }

  clearData() {
    subject.add("");
    textEditingController.text = "";
  }

  Widget _createRecipeItem(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipeWeb(url: recipe.href, item: recipe.title),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Image.network(
                  recipe.thumbnail,
                  height: 80.0,
                  width: 80.0,
                  fit: BoxFit.fitHeight,
                ),
                Expanded(
                  child: Container(
                    height: 80.0,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _createRecipeItemDescriptionSection(context, recipe),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 15.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _createRecipeItemDescriptionSection(
      BuildContext context, Recipe recipe) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          recipe.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          recipe.ingredients,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(600.0),
        child: const Text(''),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
        child: Column(
          children: <Widget>[
            _createSearchBar(context),
            Expanded(
              child: Card(
                child: _isLoading
                    ? Container(
                        child: Center(child: CircularProgressIndicator()),
                        padding: EdgeInsets.all(16.0),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _createRecipeItem(context, _items[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Recipe {
  String title, thumbnail, href, ingredients;

  Recipe(
      {required this.title,
      required this.href,
      required this.ingredients,
      required this.thumbnail});

  factory Recipe.fromJson(Map<String, dynamic> recipe) {
    return Recipe(
      title: recipe['title'],
      href: recipe['href'],
      ingredients: recipe['ingredients'],
      thumbnail: recipe['thumbnail'].toString().isEmpty
          ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/No_image_available_600_x_450.svg/600px-No_image_available_600_x_450.svg.png'
          : recipe['thumbnail'],
    );
  }
}
