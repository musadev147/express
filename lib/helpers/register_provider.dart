
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../provider/singnup_provider.dart';
import '../provider/carosul_provider.dart';
import '../provider/forget_password_provider.dart';

var providers = [
  ChangeNotifierProvider<ForgetPasswordProvider>(
    create: ((context) => ForgetPasswordProvider()),
  ),

  ChangeNotifierProvider<SignupProvider>(
    create: ((context) => SignupProvider()),
  ),

  ChangeNotifierProvider<ProfileProvider>(
    create: ((context) => ProfileProvider()),
  ),

  ChangeNotifierProvider<CarosulProvider>(
    create: ((context) => CarosulProvider()),
  ),
];
