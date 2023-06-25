import 'package:flutter/material.dart';
enum Categories{vegetables,fruit,meat,dairy,carbs,sweets,spices,convenience,hygiene,other}

class Category{
  Category(this.products ,this.color);
   String products;
   Color color;

}