import 'package:flutter/material.dart';
import 'package:shop_now/data/dummy_items.dart';
import 'package:shop_now/models/grocery_item.dart';
import 'package:shop_now/screen/new_form.dart';
// import 'package:shop_now/models/grocery_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<GroceryItem> newGrocery = [];
  void _addText() async {
    var _newListItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewFormScreen(),
      ),
    );
    if (_newListItem == null) {
      return;
    } else {
      setState(() {
        newGrocery.add(_newListItem);
      });
      // groceryItems.add(_newListItem);
    }
  }
  void removeItem(GroceryItem item){
    setState(() {
      newGrocery.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content=const Center(
                    child: Text('No items left behind'),
                  );
     if (newGrocery.isNotEmpty){
      content=ListView.builder(
                    itemCount: newGrocery.length,
                    itemBuilder: (context, index) => Dismissible(
                      onDismissed: (direction) => removeItem(newGrocery[index]),
                          key: ValueKey(newGrocery[index].name),
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              color: newGrocery[index].category.color,
                            ),
                            title: Text(
                              newGrocery[index].name,
                            ),
                            trailing: Text('${newGrocery[index].quantity}'),
                          ),
                        ));
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
            child:content
            
          ),
        ));
  }
}
