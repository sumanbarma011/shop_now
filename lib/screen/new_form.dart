import 'package:flutter/material.dart';
import 'package:shop_now/data/categories.dart';
import 'package:shop_now/models/category.dart';

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
  int _enteredQuantity = 1;
  // var dropItem= categories[Categories.vegetables];

  
  void _saveData() {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      print(_enteredQuantity);
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
                  onSaved: (newValue) => _enteredName=newValue!,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredQuantity.toString(),
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
                        onSaved: (newValue) =>
                            _enteredQuantity = int.parse(newValue!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        
                        items: [
                        for (final category in categories.entries)//for looping the maps on dart we use entries
                          DropdownMenuItem(
                              value: categories.values,
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
                      ], onChanged: (value) {}),
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
                      onPressed: () {
                        _formkey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveData,
                      child: const Text('Add item'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
