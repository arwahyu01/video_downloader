import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
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
    if (textController.text.isNotEmpty) {
      createFolder();
      isLoading.value = true;
      var result = await ApiService.getListVideo(textController.text.toString(), Get.arguments.split('/').last);
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
    // ctrlAds.showInterstitialAd();
    createFolder();
    showProgress();
    var targetPath = "${currentPath.value}/${DateTime.now()}.mp4";
    print(url);
    await dio.download(url, targetPath, onReceiveProgress: (rec, total) {
      var count = ((rec / total) * 100).toInt();
      progress.value = count.isNegative ? 0 : count;
      if (rec == total) {
        Get.back();
        Get.snackbar('Success', 'Wait a moment, your video is being processed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 2),
            colorText: Colors.white);
        Future.delayed(const Duration(seconds: 2), () {
          ctrlDownload.files.add(targetPath);
          Get.toNamed('/video-player', arguments: targetPath);
        });
      }else{
        File(targetPath).length().then((value) {
          if (value == rec) {
            Get.back();
            Get.snackbar('Success', 'Wait a moment, your video is being processed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 2),
                colorText: Colors.white);
            Future.delayed(const Duration(seconds: 2), () {
              ctrlDownload.files.add(targetPath);
              Get.toNamed('/video-player', arguments: targetPath);
            });
          }
        });

      }
    }).catchError((e) async {
      Get.back();
      Get.snackbar('Error', 'Failed to download video, please try again later',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(10),
          colorText: Colors.white);
      return throw Exception(e);
    });
  }

  Future<void> createFolder() async {
    await Permission.storage.request();
    var tempDir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    if (Get.arguments != null) {
      final Directory directory = Directory('${tempDir.toString()}${Get.arguments}');
      if (!directory.existsSync()) {
        Directory('${tempDir.toString()}${Get.arguments}').create(recursive: true);
      }
      currentPath.value = '${tempDir.toString()}${Get.arguments}';
    } else {
      currentPath.value = tempDir.toString();
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
}
