import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('In the SplashPage');
    return const Scaffold(body: Center(child: Text('Splash Page')));
  }
}
