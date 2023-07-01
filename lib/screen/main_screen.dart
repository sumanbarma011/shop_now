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
  
  List<GroceryItem> _newGrocery = [];

  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    _loadedItems = responseItem();

    super.initState();
  }

  Future<List<GroceryItem>> responseItem() async {
    final url = Uri.https(
        'shopnow-36c43-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);
    print(response.body);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch the data ");
    }

    if (response.body == 'null') {
      return []; // all the overall code of this function is skipped
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
    return loadedItem;
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
    


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [IconButton(onPressed: _addText, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No items left behind'),
            );
          }
          return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => Dismissible(
                onDismissed: (direction) => removeItem(snapshot.data![index]),
                key: ValueKey(snapshot.data![index].name),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: snapshot.data![index].category.color,
                  ),
                  title: Text(
                    snapshot.data![index].name,
                  ),
                  trailing: Text('${snapshot.data![index].quantity}'),
                ),
              ));
        },
      ),
    );
  }
}
