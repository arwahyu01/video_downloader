import 'package:get/get.dart';
import 'AdsController.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../service/api.dart';

class SplashController extends GetxController {
  final adsCtrl = Get.put(AdsController());
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  Future<void> onInit() async {
    super.onInit();
    // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    adsCtrl.loadAdOpen();
    if (await ApiService.checkInternet()) {
      Future.delayed(const Duration(seconds: 5), () {
        if (ApiService.appStatus == '1') {
          adsCtrl.showAppOpenIfAvailable();
          Future.delayed(const Duration(seconds: 1), () {
            initDynamicLinks();
          });
        } else {
          Get.offNamed('/maintenance', arguments: "Our server is under maintenance, please try again later :(");
        }
      });
    } else {
      Get.offNamed('/maintenance', arguments: 'No Internet Connection, Please check your connection and try again :)');
    }
  }

  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      Get.offAndToNamed('/${deepLink.pathSegments[0]}');
    } else {
      Get.toNamed('/home');
    }
  }
}
