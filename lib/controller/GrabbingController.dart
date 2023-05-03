import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'AdsController.dart';
import 'DownloadedController.dart';
import '../service/api.dart';

class GrabbingController extends GetxController {
  final textController = TextEditingController();
  final ctrlAds = Get.put(AdsController());
  final ctrlDownload = Get.put(DownloadedController());
  var listData = [].obs;
  var isLoading = false.obs;
  var folder = ''.obs;
  var dio = Dio();
  var progress = 0.obs;
  var currentPath = ''.obs;
  var arguments = ''.obs;

  @override
  void onInit() {
    super.onInit();
    createFolder();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void pasteFromClipboard(category) {
    textController.clear();
    category = category.split('/').last;
    Future.delayed(const Duration(milliseconds: 100), () async {
      Clipboard.getData('text/plain').then((value) {
        if (value != null) {
          var url = value.text;
          if (url != null) {
            var check = category == 'facebook' ? 'fb.watch' : "$category.com";
                check = category == 'youtube' ? 'youtu.be' : check;
            if (url.contains(check)) {
              textController.text = url;
              Future.delayed(const Duration(milliseconds: 100), () {
                search();
              });
            } else {
                if (url.contains("$category.com")) {
                  textController.text = url;
                  Future.delayed(const Duration(milliseconds: 100), () {
                    search();
                  });
                } else {
                  textController.text = url;
                  Get.snackbar('Error', 'Invalid URL, your url is not from $category',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(10),
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                }
            }
          }
        }
      });
    });
  }

  void search() async {
    var target = Get.arguments;
    if (textController.text.isNotEmpty) {
      createFolder();
      isLoading.value = true;
      var result = await ApiService.getListVideo(textController.text.toString(), target.split('/').last);
      if (result.isNotEmpty) {
        isLoading.value = false;
        listData.value = result;
      } else {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to get data, please try again later',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            margin: const EdgeInsets.all(10),
            colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'Please input ${Get.arguments} url',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> downloadVideo(url) async {
    ctrlAds.showInterstitialAd();
    createFolder();
    showProgress();
    var targetPath = "${currentPath.value}/video-${DateTime.now().millisecond}.mp4";
    await dio.download(url, targetPath, onReceiveProgress: (rec, total) {
      var count = ((rec / total) * 100).toInt();
      progress.value = count.isNegative ? 0 : count;
    }).catchError((e) async {
      Get.back();
      progress.value = 0;
      Get.snackbar('Error', 'Failed to download video, please try again later',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(10),
          colorText: Colors.white);
      return throw Exception(e);
    }).then((value) => {
      Get.back(),
      progress.value = 0,
      Future.delayed(const Duration(seconds: 1), () {
          ctrlDownload.files.add(targetPath);
          Get.toNamed('/video-player', arguments: targetPath);
        }),
    });
  }

  Future<void> createFolder() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var target = Get.arguments;
    var tempDir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);

    if(androidInfo.version.sdkInt < 30) await Permission.storage.request();

    currentPath.value = tempDir.toString();
    if (Get.arguments != null) {
      Directory('${tempDir.toString()}$target').create(recursive: true);
      if (Directory('${tempDir.toString()}$target').existsSync()) {
        currentPath.value = '${tempDir.toString()}$target';
      }
    }
  }

  void showProgress() {
    Get.dialog(
      Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CircularProgressIndicator(color: Colors.green, strokeWidth: 5),
            ),
          ),
          Obx(() => Center(
                child: DefaultTextStyle(
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  child: Text('${progress.value}%'),
                ),
              ))
        ],
      ),
      barrierDismissible: false,
    );
  }

  thumbnailGenerate(data) {
    if (data.image != '') {
      return Image.network(
        data.image,
        alignment: Alignment.center,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 20),
              Icon(Icons.error, color: Colors.red, size: 50),
              Text('Image not found or invalid link !'),
            ],
          );
        },
        fit: BoxFit.cover,
      );
    } else {
      return ctrlDownload.showThumbnailVideo(data.url);
    }
  }

  void openUrl(String s) {
    Get.dialog(
        useSafeArea: true,
        transitionCurve: Curves.easeInOut,
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse("${ApiService.baseUrlGrab}/help.php?p=$s")),
          onEnterFullscreen: (controller) {
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
          },
          onWebViewCreated: (controller) {},
          initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(javaScriptEnabled: true, supportZoom: true)),
          onLoadStart: (controller, url) {},
          onLoadError: (controller, url, code, message) {},
          onLoadHttpError: (controller, url, code, message) {},
        ));
  }
}
