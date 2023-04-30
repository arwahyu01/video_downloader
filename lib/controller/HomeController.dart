import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AdsController.dart';
import 'GrabbingController.dart';
import '../service/api.dart';
import '../view/widget/Function.dart';

class HomeController extends GetxController {
  final ctrlAds = Get.put(AdsController());
  final ctrlGrab = Get.put(GrabbingController());
  var listMenu = [].obs;

  @override
  void onInit() {
    super.onInit();
    ctrlAds.createInterAds();
    checkUpdate();
    getListMenu();
  }

  Future<void> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version.toString() != ApiService.appVersion.toString()) {
      if (ApiService.appAlertStatus != 0) {
        Get.defaultDialog(
          title: ApiService.appAlertTitle.toString(),
          middleText: ApiService.appAlertContent.toString(),
          confirmTextColor: Colors.white,
          barrierDismissible: false,
          onWillPop: () async => false,
          actions: [
            TextButton(
              onPressed: () async => await launchUrl(Uri.parse(ApiService.appAlertLink.toString()), mode: LaunchMode.externalApplication),
              child: const Text('Ok'),
            ),
            if (ApiService.appAlertStatus != 2)
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))
          ],
        );
      }
    }
  }

  goToPage(String page) {
    ctrlAds.showInterstitialAd();
    showLoadingModal();
    Future.delayed(const Duration(seconds: 2), () {
      ctrlGrab.textController.clear();
      ctrlGrab.listData.clear();
      Get.back();
      if(page == '/downloaded') {
        Get.toNamed(page, arguments: page);
      }else {
        Get.toNamed('/grab', arguments: page);
      }
    });
  }

  getListMenu(){
    return ApiService.getMenu().then((value) => listMenu.value = value);
  }
}
