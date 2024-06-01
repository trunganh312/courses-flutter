import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList2 extends StatefulWidget {
  const GroceryList2({super.key});

  @override
  State<GroceryList2> createState() => _GroceryList2State();
}

class _GroceryList2State extends State<GroceryList2> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = false;
  String? _error;
  void _loadData() async {
    final url = Uri.https(
        'flutter-prep-d040d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');
    try {
      setState(() {
        _isLoading = true;
      });

      final respone = await http.get(url);
      if (respone.statusCode == 404) {
        setState(() {
          _error = "Please try again. Failed to fetch data.";
        });
      }
      if (respone.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> data = json.decode(respone.body);
      final List<GroceryItem> loaditems = [];
      for (var item in data.entries) {
        final category = categories.entries
            .firstWhere(
              (element) => element.value.title == item.value['category'],
            )
            .value;

        loaditems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
        setState(() {
          _groceryItems = loaditems;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Something error. Failed to fetch data.";
      });
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _addItem() async {
    final groceryItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const NewItem(),
    ));

    if (groceryItem != null) {
      setState(() {
        _groceryItems.add(groceryItem);
      });
    }
  }

  void _deleteGrocery(DismissDirection direction) async {
    final id = _groceryItems[direction == DismissDirection.endToStart
            ? 0
            : _groceryItems.length - 1]
        .id;
    final url = Uri.https(
        'flutter-prep-d040d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/$id.json');
    final respone = await http.delete(url);
    if (respone.statusCode == 200) {
      setState(() {
        _groceryItems.removeAt(direction == DismissDirection.endToStart
            ? 0
            : _groceryItems.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(_groceryItems[index].id),
        onDismissed: _deleteGrocery,
        direction: DismissDirection.endToStart,
        child: ListTile(
          title: Text(_groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: _groceryItems[index].category.color,
          ),
          trailing: Text(
            _groceryItems[index].quantity.toString(),
          ),
        ),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isEmpty && !_isLoading) {
      content = const Center(
        child: Text('No groceries yet'),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
}
