import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

import 'package:flutter/material.dart';

class TextformField extends StatefulWidget {
  final TextEditingController textFormFieldController;
  final String labelText;
  final bool? prefixIcon;

  const TextformField({
    Key? key,
    required this.textFormFieldController,
    required this.labelText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  _TextformFieldState createState() => _TextformFieldState();
}

class _TextformFieldState extends State<TextformField> {
  @override
  void initState() {
    super.initState();
    widget.textFormFieldController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.textFormFieldController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 30.sp, right: 30.sp),
      decoration: BoxDecoration(
          color: AppColors.hintTextColor1,
          borderRadius: BorderRadius.circular(30.sp)),
      child: TextField(
        controller: widget.textFormFieldController,
        decoration: InputDecoration(
          hintText: widget.labelText,
          hintStyle: const TextStyle(color: AppColors.hintTextColor),
          border: InputBorder.none,
          prefixIcon: widget.prefixIcon == null || widget.prefixIcon == false
              ? null
              : const Icon(Icons.search),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 50.w, vertical: 9.h),
          suffixIcon: widget.textFormFieldController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () => widget.textFormFieldController.clear(),
                  icon: const Icon(Icons.cancel),
                ),
        ),
      ),
    );
  }
}

// class TextformField extends StatelessWidget {
//   final TextEditingController textFormFieldController;
//   final String labelText;
//   final bool? prefixIcon;

//   TextformField(
//       {required this.textFormFieldController,
//       required this.labelText,
//       this.prefixIcon}) {
//     textFormFieldController.addListener(() {
//       // Trigger a rebuild whenever the text changes
//       WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Container(
//       margin: EdgeInsets.only(left: 30.sp, right: 30.sp),
//       decoration: BoxDecoration(
//           color: AppColors.hintTextColor1,
//           borderRadius: BorderRadius.circular(30.sp)),
//       child: TextField(
//         controller: textFormFieldController,
//         decoration: InputDecoration(
//             hintText: labelText,
//             hintStyle: TextStyle(color: AppColors.hintTextColor),
//             border: InputBorder.none,
//             prefixIcon: prefixIcon == null || prefixIcon == false
//                 ? null
//                 : Icon(Icons.search),
//             contentPadding:
//                 EdgeInsets.symmetric(horizontal: 50.w, vertical: 9.h),
//             suffixIcon: textFormFieldController.text.isEmpty
//                 ? null
//                 : IconButton(
//                     onPressed: () => textFormFieldController.clear(),
//                     icon: Icon(Icons.cancel))),
//       ),
//     );
//   }
// }
