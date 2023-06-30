import 'dart:convert'; //json.encode header file

import 'package:flutter/material.dart';
import 'package:shop_now/data/categories.dart';

import 'package:shop_now/models/grocery_item.dart';
import 'package:shop_now/screen/new_form.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? errorText;
  List<GroceryItem> _newGrocery = [];
  bool _loadingData = true;
  @override
  void initState() {
    responseItem();

    super.initState();
  }

  void responseItem() async {
    final url = Uri.https(
        'shopnow-36c43-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);
      print(response.body);

      if (response.body == 'null') {
        setState(() {
          _loadingData = false;
        });

        return; // all the overall code of this function is skipped
      }
      final List<GroceryItem> loadedItem = [];

      final Map<String, dynamic> listData = json.decode(response.body);
      for (var item in listData.entries) {
        final belongCategory = categories.entries
            .firstWhere(
                (element) => element.value.products == item.value['category'])
            .value;
        loadedItem.add(GroceryItem(
            category: belongCategory,
            id: item.key,
            name: item.value['name'],
            quantity: int.parse(item.value['quantity'])));
      }
      setState(() {
        _loadingData = false;
        _newGrocery = loadedItem;
      });
    } catch (error) {
      setState(() {
        errorText = "Something went wrong. Please Try Later................";
      });
    }
  }

//--------------------------- Function of the icon add button ----------------------------------------//

  void _addText() async {
    final addedData = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewFormScreen(),
      ),
    );
    if (addedData == null) {
      return;
    }
    setState(() {
      _newGrocery.add(addedData);
    });
  }

// this function is for removing the items created for the dismissable widget

  void removeItem(GroceryItem item) async {
    final int index = _newGrocery.indexOf(item);

    setState(() {
      _newGrocery.remove(item);
    });

    final url = Uri.https('shopnow-36c43-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _newGrocery.insert(index, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Something error with deletion',
        ),
        duration: Duration(milliseconds: 300),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items left behind'),
    );
    if (_loadingData) {
      content = const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }
    if (_newGrocery.isNotEmpty) {
      content = ListView.builder(
          itemCount: _newGrocery.length,
          itemBuilder: (context, index) => Dismissible(
                onDismissed: (direction) => removeItem(_newGrocery[index]),
                key: ValueKey(_newGrocery[index].name),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _newGrocery[index].category.color,
                  ),
                  title: Text(
                    _newGrocery[index].name,
                  ),
                  trailing: Text('${_newGrocery[index].quantity}'),
                ),
              ));
    }
    if (errorText != null) {
      content = Center(
        child: Text(errorText!),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Groceries',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            IconButton(onPressed: _addText, icon: const Icon(Icons.add))
          ],
        ),
        body: SafeArea(
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: content,
          ),
        ));
  }
}
