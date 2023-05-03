import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:social_share/social_share.dart';

showLoadingModal() {
  Get.dialog(
    loading(),
    barrierDismissible: false,
  );
}

loading() {
  return Center(
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

reviewApp() async {
  final InAppReview inAppReview = InAppReview.instance;
  if (await inAppReview.isAvailable()) {
    inAppReview.openStoreListing();
  } else {
    Get.snackbar('Error', 'Failed to open link review',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
  }
}

shareApp() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  SocialShare.shareOptions(
      "Hi, I'm using ${packageInfo.appName} to download videos from TikTok, Instagram, Facebook, Twitter, and more. \n\n Download now https://play.google.com/store/apps/details?id=${packageInfo.packageName}",
      imagePath: null);
}

openDialogRate() {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Rate App'),
      content: const Text(
          'Please rate our app, it will help us to improve our app in the future :)'),
      actions: [
        TextButton(
          onPressed: () => exit(0),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => reviewApp(),
          child: const Text('Ok, Rate Now'),
        ),
      ],
    ),
  ).then((value) {
    if (value == true) {
      Get.back(result: true);
    }
  });
}



Future<void> requestReviewApp() async {
  final InAppReview inAppReview = InAppReview.instance;
  if (Platform.isAndroid) {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      Get.snackbar('Error', 'Failed to open link review', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
