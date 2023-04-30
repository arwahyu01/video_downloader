import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Maintenance extends StatelessWidget {
  const Maintenance({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_sharp, size: 100),
              const SizedBox(height: 20),
              Text(Get.arguments.toString(),
                  style: const TextStyle(fontSize: 20, wordSpacing: 2)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
