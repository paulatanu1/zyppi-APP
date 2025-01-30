import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';

class TextInputFieldContainer extends StatelessWidget {
  final String inputFieldName;
  final TextEditingController controller;
  const TextInputFieldContainer({super.key, required this.inputFieldName, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.lightBlue3, AppColors.lightBlue4], // Gradient Left to Right
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          suffixIcon: IconButton(
            icon: Icon(Icons.edit, color: AppColors.darkBlue),
            onPressed: () {
              controller.clear(); // Clear input field
            },
          ), // Suffix Icon (Clear Button)
          hintText: inputFieldName,
          hintStyle: TextStyle(color: AppColors.darkBlue),
          border: InputBorder.none, // Removes default border
        ),
      ),
    );
  }
}
