import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Espera un segundo para que se vea el splash
    await Future.delayed(const Duration(seconds: 1));

    final authCtrl = Get.find<AuthController>();
    final loggedIn = await authCtrl.checkAuth();

    if (loggedIn) {
      Get.offAll(() => HomePage());
    } else {
      Get.offAll(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
