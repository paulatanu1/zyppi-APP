import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';

class DropdownExpansionTile extends StatefulWidget {

   String dropDownTitle;
   String dropDownContent;
    final Widget? dynamicWidget;
   DropdownExpansionTile({Key? key, required this.dropDownTitle, required this.dropDownContent, this.dynamicWidget}) : super(key: key);

  @override
  _DropdownExpansionTileState createState() => _DropdownExpansionTileState();
}

class _DropdownExpansionTileState extends State<DropdownExpansionTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.only(top: height*0.015, bottom: height*0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpansion,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  widget.dropDownTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.darkBlue,
                      fontSize: 16),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.dynamicWidget != null) widget.dynamicWidget!,                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_outlined: Icons.arrow_forward_ios,
                      size: 20,weight: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height*0.015),
                Text(
                  widget.dropDownContent,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.grey3,
                    fontSize: 13,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
