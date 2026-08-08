// import 'package:flutter/material.dart';
// import 'constants/app_constants.dart';
// import 'helpers/di.dart';
// import 'helpers/helper_methods.dart';
// import 'welcome_screen.dart';
//
// final class Loading extends StatefulWidget {
//   const Loading({super.key});
//
//   @override
//   State<Loading> createState() => _LoadingState();
// }
//
// class _LoadingState extends State<Loading> {
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     loadInitialData();
//     super.initState();
//   }
//
//   loadInitialData() async {
//     await Future.delayed(Durations.extralong2);
//     await setInitValue();
//     // if (appData.read(kKeyIsLoggedIn)) {
//     //   String token = appData.read(kKeyToken);
//     //   DioSingleton.instance.update(token);
//     // }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const WelcomeScreen();
//     } else {
//       // return BottomNavBar();
//
//       return appData.read(kKeyIsLoggedIn)
//           ? const BottomNavBar(selectIndex: 0)
//           : const OnBoardingScreen1();
//     }
//   }
// }
