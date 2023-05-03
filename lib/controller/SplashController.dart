import 'package:get/get.dart';
import 'AdsController.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import '../service/api.dart';

class SplashController extends GetxController {
  final adsCtrl = Get.put(AdsController());

  @override
  Future<void> onInit() async {
    super.onInit();
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      adsCtrl.loadAdOpen();
      Future.delayed(const Duration(seconds: 4), () {
        if (ApiService.appStatus == '1') {
          adsCtrl.showAppOpenIfAvailable();
          Future.delayed(const Duration(seconds: 1), () {
            Get.toNamed('/home');
          });
        } else {
          Get.offNamed('/maintenance', arguments: "Our server is under maintenance, please try again later :(");
        }
      });
  }
}
