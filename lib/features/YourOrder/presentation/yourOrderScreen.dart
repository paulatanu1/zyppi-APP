import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';
import '../widgets/yourOrderWidget.dart';

class YourOrderScreen extends StatefulWidget {
  const YourOrderScreen({super.key});

  @override
  State<YourOrderScreen> createState() => _YourOrderScreenState();
}

class _YourOrderScreenState extends State<YourOrderScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                    )),
                SizedBox(
                  width: width * 0.02,
                ),
                Text(
                  'yourOrder'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.darkBlue,
                      fontStyle: FontStyle.italic,
                      fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.025,
            ),
            Divider(
              height: 1,
              color: AppColors.grey5,
            ),
            SizedBox(
              height: height * 0.025,
            ),

            Expanded(
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return YourOrderWidget(
                      onClicked: (){
                        _showBottomSheet(context);
                      },
                    );
                  }),
            ),
            Spacer(),
            Column(
              children: [
                Image.asset(
                  'assets/images/prof_logo.png', height: height * 0.05,
                  width: width * 0.3,),
                Text(
                  'v1.0.0'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.grey7,
                      fontSize: 12),
                ),
              ],
            )


          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // BottomSheet will take default height
      backgroundColor: Colors.transparent, // Transparent background
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none, // Allows the close icon to be positioned outside
          children: [
            // White BottomSheet Container - Positioned at Bottom
            Positioned(
              bottom: 0, // Stick to bottom of the screen
              left: 0,
              right: 0,
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(height * 0.02),
                    topRight: Radius.circular(height * 0.02),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'orderInfo'.tr(), // Use 'orderInfo'.tr() if translation is needed
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // Action Container
                      Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(height * 0.02),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _actionRow(
                              icon: Icons.delete,
                              text: 'deleteOrder'.tr(),
                              iconColor: Colors.red,
                              onTap: () {
                                // Add your delete order logic here
                                Navigator.pop(context);
                              },
                            ),
                            Divider(),
                            _actionRow(
                              icon: Icons.share,
                              text: 'shareItems'.tr(),
                              iconColor: Colors.blue,
                              onTap: () {
                                // Add your share logic here
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Centered Close Icon Above the BottomSheet
            Positioned(
              bottom: height * 0.35 - 52, // Just above the bottom sheet
              left: width * 0.5 - 22, // Centers the icon
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child: Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _actionRow({required IconData icon, required String text, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }


}
