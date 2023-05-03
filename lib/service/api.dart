import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Grabbing.dart';
import '../model/Menu.dart';
import '../model/AppInfo.dart';

class ApiService extends GetxController{
  static const String _baseUrl = 'https://panel.footballuwu.site/api';
  static const String baseUrlGrab = 'https://footballuwu.site/video-downloader';
  static String slugPackageName = '';
  static String? appName = 'All Video DownloaderAll';
  static int? appVersion = 1;
  static String? appStatus = '1';

  static String? appAlertTitle = 'Alert';
  static String? appAlertContent = 'Content';
  static int? appAlertStatus = 0;
  static String? appAlertLink = '';
  static var typeAds = ''.obs;
  static dynamic adsSetting = '';
  static dynamic adsUnitId = '';
  static dynamic appAlert;


  static Future<bool> checkInternet() async {
    try {
      final connect = await InternetAddress.lookup('google.com');
      if (connect.isNotEmpty && connect[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static Future<void> requestReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      Get.snackbar('Error', 'Failed to open link review', snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<AppInfo?> getAppInfo() async {
    var response = await http.get(Uri.parse('$_baseUrl/app/$slugPackageName'));
    if (response.statusCode == 200) {
      var res = AppInfo.fromJson(jsonDecode(response.body));
      appName = res.name;
      appVersion = res.version;
      appStatus = res.status;
      appAlertTitle = res.alert.title;
      appAlertContent = res.alert.content;
      appAlertStatus = res.alert.status;
      appAlertLink = res.alert.link;
    }
    return null;
  }

  static Future<void> getAds() async {
    final response = await http.get(Uri.parse('$_baseUrl/iklan/$slugPackageName'));
    if (response.statusCode == 200) {
      var decode = jsonDecode(response.body);
      adsUnitId = decode;
      typeAds.value = decode['code']; // admob, facebook, applovin
      adsSetting = decode['setting'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('app_open', decode['app_open']);
    }
  }

  static Future<List<Menu>> getMenu() async {
    var response = await http.get(Uri.parse('$baseUrlGrab/downloader.php?action=menu'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return menuFromJson(jsonString);
    }
    return [];
  }

  static Future<List<Grabbing>> getListVideo(url,category) async {
    var response = await http.post(Uri.parse('$baseUrlGrab/downloader.php?action=$category'),body: {'url': url});
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return grabbingFromJson(jsonString);
    }
    return [];
  }
}