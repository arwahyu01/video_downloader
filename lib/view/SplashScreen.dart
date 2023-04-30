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
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 7,
                backgroundColor: Colors.blueGrey,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 10,
                value: 0.9,
                backgroundColor: Colors.black
              ),
            ),
          ),
          Center(
            child: Icon(Icons.video_collection_sharp, size: 100, color: Colors.white)
          ),
          Positioned(
              bottom: 220,
              right: 58,
              top: 0,
              left: 0,
              child: Icon(Icons.add, size: 110, color: Colors.white)),
        ],
      ),
    );
  }
}
