import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned(top: 200, width: 80, height: 80, child: Image.asset('assets/img/logo.png')),
          const Positioned(bottom: 30, child: Text('素典'))
        ],
      ),
    );
  }
}
