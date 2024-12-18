import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';

class Categories extends StatefulWidget {
  CategoriesState createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Fresh Fruits & Vegetables',
      'color': Color.fromRGBO(83, 177, 117, 0.1),
      'borderColor': Color.fromRGBO(83, 177, 117, 1),
      'image': 'assets/images/category.png'
    },
    {
      'name': 'Bread & Eggs',
      'color': Color.fromRGBO(255, 236, 247, 1),
      'borderColor': Color.fromRGBO(251, 84, 182, 1),
      'image': 'assets/images/bread.png'
    },
    {
      'name': 'Atta, Rice & Dals',
      'color': Color.fromRGBO(248, 164, 76, 0.1),
      'borderColor': Color.fromRGBO(250, 189, 124, 1),
      'image': 'assets/images/rice.png'
    },
    {
      'name': 'Masala & Dry Fruits',
      'color': Color.fromRGBO(237, 247, 253, 1),
      'borderColor': Color.fromRGBO(82, 186, 244, 1),
      'image': 'assets/images/category.png'
    },
    {
      'name': 'Cooking Oil & Ghee',
      'color': Color.fromRGBO(248, 164, 76, 0.1),
      'borderColor': Color.fromRGBO(248, 164, 76, 0.7),
      'image': 'assets/images/oil.png'
    },
    {
      'name': 'Meat & Fish',
      'color': Color.fromRGBO(247, 165, 147, 0.25),
      'borderColor': Color.fromRGBO(247, 165, 147, 1),
      'image': 'assets/images/meat.png'
    },
    {
      'name': 'Bakery & Snacks',
      'color': Color.fromRGBO(211, 176, 224, 0.25),
      'borderColor': Color.fromRGBO(211, 176, 224, 1),
      'image': 'assets/images/bread.png'
    },
    {
      'name': 'Dairy & Eggs',
      'color': Color.fromRGBO(253, 229, 152, 0.25),
      'borderColor': Color.fromRGBO(253, 229, 152, 1),
      'image': 'assets/images/milk.png'
    },
    {
      'name': 'Beverages',
      'color': Color.fromRGBO(183, 223, 245, 0.25),
      'borderColor': Color.fromRGBO(183, 223, 245, 1),
      'image': 'assets/images/beverages.png'
    }
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 40.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(
            categoryText: categories[index]['name'], imageUrl: categories[index]['image'], backgroundColor: categories[index]['color'], borderColor: categories[index]['borderColor']);
      },
    );
  }
}
