// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class BackButtonHandler extends StatelessWidget {
//   final Widget child;

//   const BackButtonHandler({Key? key, required this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (GoRouter.of(context).canPop()) {
//           // If there's a page to pop, navigate back
//           GoRouter.of(context).pop();
//           return false;
//         } else {
//           // Allow the default system back behavior if there's no previous page
//           return true;
//         }
//       },
//       child: child,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonHandler extends StatelessWidget {
  final Widget child;

  const BackButtonHandler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GoRouter.of(context).pop();
        return true;
      },
      child: child,
    );
  }
}
