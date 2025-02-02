import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/features/CategoryDetails/widgets/category_details_header.dart';
import 'package:zippy/core/commonWidgets/itemCard.dart';
import 'package:zippy/core/constants/colors.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: height * 0.025,
              right: height * 0.025,
              bottom: height * 0.025),
          child: Column(
            children: [
              CategoryDetailsHeader(
                onFilterIconClicked: () {
                  context.go('/filterScreen');
                },
              ),
              SizedBox(
                height: height * 0.025,
              ),
              Expanded(
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: height * 0.015,
                      mainAxisSpacing: height * 0.015,
                      childAspectRatio: 0.8),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return ItemCard(
                        onClicked: () {},
                        productName: 'Fresh Apple Juice',
                        quantity: '2L',
                        price: '80');
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
