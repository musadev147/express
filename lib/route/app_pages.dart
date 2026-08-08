import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common_wigdets/custom_navigation.dart';
import '../common_wigdets/splash_screen.dart';
import '../common_wigdets/onboarding_screen.dart';
import '../common_wigdets/login_screen.dart';
import '../featuers/customer/customer_home_screen.dart';
import '../common_wigdets/profile_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingScreen(
        selectedRole: Get.arguments,
      ),
    ),

    GetPage(
      name: Routes.LOGIN,
      page: () => SignInScreen(role: Get.arguments ?? 'customer'),
    ),

    GetPage(
      name: Routes.NAV,
      page: () => CustomNavigation(
        role: Get.arguments,
      ),
    ),

    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),

    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(points: 100),
    ),
  ];
}

// Simple fallback HomeScreen class
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const CustomerHomeScreen();
}
