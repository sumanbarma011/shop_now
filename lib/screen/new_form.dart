import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shop_now/data/categories.dart';
import 'package:shop_now/models/category.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop_now/models/grocery_item.dart';

class NewFormScreen extends StatefulWidget {
  const NewFormScreen({super.key});
  @override
  State<NewFormScreen> createState() {
    return _NewFormScreen();
  }
}

class _NewFormScreen extends State<NewFormScreen> {
  final _formkey = GlobalKey<FormState>();
  String _enteredName = '';
  String _enteredQuantity = '1';
  var _selectedCategory = categories[Categories.vegetables];
  bool _setData = false;

  void _saveData() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _setData = true;
      });
      final url = Uri.https(
          'shopnow-36c43-default-rtdb.firebaseio.com', 'shopping-list.json');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'category': _selectedCategory!.products,
            'name': _enteredName,
            'quantity': _enteredQuantity
          }),
        );

        if (!context.mounted) {
          return;
        }
        log('***************************');
        print(response.body);
        final resData = json.decode(response.body);

        Navigator.of(context).pop(GroceryItem(
            category: _selectedCategory!,
            id: resData['name'],
            name: _enteredName,
            quantity: int.parse(_enteredQuantity)));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sorry!!!!!!!!!'),
          duration: Duration(milliseconds: 300),
        ));
        setState(() {
          _setData=false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fill the text form ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length >= 50) {
                      return ('Please enter a valid name of length more than 1 and less than 50');
                    } else {
                      return null;
                    }
                  },
                  onSaved: (newValue) => _enteredName = newValue!,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredQuantity,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('quantity'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value)! <= 0 ||
                              int.tryParse(value) == null) {
                            return ('Please enter a valid positive number greater than 0');
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) => _enteredQuantity = newValue!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: [
                            for (final category in categories
                                .entries) //for looping the maps on dart we use entries
                              DropdownMenuItem(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: category.value.color,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(category.value.products)
                                    ],
                                  ))
                          ],
                          onChanged: (value) {
                            _selectedCategory = value;
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _setData
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _setData ? null : _saveData,
                      child: _setData
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child:
                                  CircularProgressIndicator(color: Colors.red),
                            )
                          : const Text('Add item'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
