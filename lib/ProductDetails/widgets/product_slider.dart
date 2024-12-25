import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:zippy/Utils/colors.dart';

class ProductSlider extends StatefulWidget {
  const ProductSlider({super.key});

  @override
  State<ProductSlider> createState() => _ProductSliderState();
}

class _ProductSliderState extends State<ProductSlider> {
  int _currentIndex = 0;
  final List<Map<String, String>> _sliderItems = [
    {'image': 'assets/images/apple.png',},
    {'image': 'assets/images/apple.png',},
    {'image': 'assets/images/apple.png',},
  ];

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // TODO: implement build
    return CarouselSlider(
      items: _sliderItems.map((item) {
        return Column(
          children: [
            Container(
              width: width,
              decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(height*0.025),
                    bottomRight: Radius.circular(height*0.025)
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(top:height*0.01, left: height*0.03),
                          child: Bounce(
                              duration: Duration(milliseconds: 300),
                              onPressed: () {  },
                              child: Icon(Icons.arrow_back_ios,size: 30,weight: 2,)),
                        )
                      ],
                    ),
                    Image.asset(
                      item['image']!,
                      height: height*0.25,
                      width: width*0.6,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _sliderItems.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() => _currentIndex = entry.key),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin:  EdgeInsets.symmetric(horizontal: width*0.01),
                            width: _currentIndex == entry.key ? width*0.06 : width*0.01,
                            height: _currentIndex == entry.key ? height*0.005 : width*0.01,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _currentIndex == entry.key
                                  ? AppColors.green
                                  : AppColors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: height*0.025,)
                  ],
                ),
              ),
            ),

          ],
        );
      }).toList(),
      options: CarouselOptions(
        height: height*0.4,
        enlargeCenterPage: false,
        autoPlay: false,
        viewportFraction: 1.0, // Ensures full width is taken
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
