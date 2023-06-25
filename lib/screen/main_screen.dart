import 'package:flutter/material.dart';
import 'package:shop_now/data/dummy_items.dart';
import 'package:shop_now/screen/new_form.dart';
// import 'package:shop_now/models/grocery_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _addText(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>const NewFormScreen()));
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Groceries',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [IconButton(onPressed:_addText, icon: const  Icon(Icons.add))],
        ),
        body: SafeArea(
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: ListView.builder(
                itemCount: groceryItems.length,
                itemBuilder: (context, index) => ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: groceryItems[index].category.color,
                      ),
                      title: Text(
                        groceryItems[index].name,
                      ),
                      trailing: Text('${groceryItems[index].quantity}'),
                    )
            
                ),
          ),
        ));
  }
}
