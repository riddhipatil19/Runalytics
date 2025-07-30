import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runn_track/main_nav.dart';
import 'package:runn_track/pages/home.dart';
import 'package:runn_track/pages/login.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  bool isLogin = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
    Future.delayed(Duration(seconds: 3)).then((value) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => isLogin ? MainNavScreen() : Login()));
    });
  }

  void checkLogin() async {
    isLogin = await SharedPrefHelper.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash'),
      ),
    );
  }
}
