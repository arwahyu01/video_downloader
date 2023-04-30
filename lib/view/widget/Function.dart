import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
      "Share App from ${packageInfo.appName}, Download Now https://play.google.com/store/apps/details?id=${packageInfo.packageName}",
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

void openUrl(String s) {
  Get.dialog(
      useSafeArea: true,
      transitionCurve: Curves.easeInOut,
      InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(s)),
        onEnterFullscreen: (controller) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        onWebViewCreated: (controller) {},
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            supportZoom: true,
          ),
        ),
        onLoadStart: (controller, url) {
          if (kDebugMode) {
            print('onLoadStart: $url');
          }
        },
        onLoadError: (controller, url, code, message) {
          if (kDebugMode) {
            print('onLoadError: $url, $code, $message');
          }
        },
        onLoadHttpError: (controller, url, code, message) {
          if (kDebugMode) {
            print('onLoadHttpError: $url, $code, $message');
          }
        },
      ));
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
