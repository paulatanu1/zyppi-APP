import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/Utils/colors.dart';

class Categories extends StatefulWidget {
  CategoriesState createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  final PageController _pageController = PageController();

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
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < categories.length; i += 4) {
      chunks.add(categories.sublist(
          i, i + 4 > categories.length ? categories.length : i + 4));
    }

    // TODO: implement build
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            itemCount: chunks.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              final chunk = chunks[index];
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 40.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: chunk.length,
                itemBuilder: (context, subIndex) {
                  final item = chunk[subIndex];
                  return CategoryCard(
                      categoryText: item['name'],
                      imageUrl: item['image'],
                      backgroundColor: item['color'],
                      borderColor: item['borderColor']);
                },
              );
            },
          ),
        ),
        SizedBox(height: 15.h),
        SmoothPageIndicator(
          controller: _pageController,
          count: chunks.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 12.w,
            activeDotColor: AppColors.green,
            dotColor: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
