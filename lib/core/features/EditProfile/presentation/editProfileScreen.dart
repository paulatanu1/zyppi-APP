import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';
import 'package:zippy/core/features/EditProfile/widgets/textInputFieldContainer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                  'editProfile'.tr(),
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

            Padding(
              padding:  EdgeInsets.only(left: height*0.02, right: height*0.02),
              child: Column(
                children: [
                  TextInputFieldContainer(controller: nameController,inputFieldName: "Name",),
                  SizedBox(height: height*0.01,),

                  TextInputFieldContainer(controller: emailController,inputFieldName: "Email",),
                  SizedBox(height: height*0.01,),

                  TextInputFieldContainer(controller: phController,inputFieldName: "Phone No",),
                  SizedBox(height: height*0.01,),

                  TextInputFieldContainer(controller: dobController,inputFieldName: "Date Of Birth",),
                  SizedBox(height: height*0.01,),

                  TextInputFieldContainer(controller: genderController,inputFieldName: "Gender",),
                  SizedBox(height: height*0.01,),
                ],
              ),

            ),

            Spacer(),
            Column(
              children: [
                Image.asset('assets/images/prof_logo.png', height: height*0.05,width: width*0.3,),
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
}
