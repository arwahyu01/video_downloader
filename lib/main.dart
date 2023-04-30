import 'package:applovin_max/applovin_max.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'service/api.dart';
import 'Route/RoutePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  ApiService.slugPackageName = packageInfo.packageName.replaceAll('.', '-');
  MobileAds.instance.initialize();
  FacebookAudienceNetwork.init();
  await AppLovinMAX.initialize("MmyzbHrdywErwt8s9pRxJRX44QONi_ZPX-a290U_oATcD31doIZWrT69_4VvT7vi_tGfohSVq0CydaB1ftFz34");
  OneSignal.shared.setAppId("ae860917-1018-40f3-804c-fe9c9bd4eb4b");
  ApiService.getAppInfo();
  ApiService.getAds();
  runApp(GetMaterialApp(
    title: 'Video Downloader',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.green),
    initialRoute: '/splashscreen',
    getPages: RoutePage.page,
  ));
}