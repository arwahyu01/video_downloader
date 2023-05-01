import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/SplashController.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final ctrl = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: const [
          Center(
              child: Icon(Icons.add_a_photo_outlined,
                  size: 80, color: Colors.white)),
          Center(
            child: SizedBox(
              width: 205,
              height: 205,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 8,
                  value: 0.2,
                  backgroundColor: Colors.black),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            top: 13,
            left: 7,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 155,
              height: 155,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 7,
                value: 0.2,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 105,
              height: 105,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 7,
                value: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
