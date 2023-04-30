import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'AdsController.dart';
import '../view/widget/Function.dart';

class FolderController extends GetxController {
  var dio = Dio();
  var tabActive = 0.obs;
  var files = [].obs;
  var totalFiles = 0.obs;
  final ctrlAds = Get.put(AdsController());

  @override
  void onInit() async {
    super.onInit();
    loadImported();
  }

  void loadImported() {
    files.value = [];
    print(Get.arguments);
    Directory(Get.arguments).list(recursive: true).listen((file) {
      if (file.path.endsWith('.mp4')) {
        files.add(file.path);
      } else {
        getMp4Files(file.path);
      }
    });
    for (var i = 0; i < files.length; i++) {
      if (i % 4 == 0) {
        files.insert(i, 'ADS');
      }
    }
  }

  void getMp4Files(path) {
    FileStat.stat(path).then((value) {
      if (value.type == FileSystemEntityType.directory) {
        Directory(path).list(recursive: false).listen((file) {
          if (file.path.endsWith('.mp4')) {
            files.add(file.path);
          } else {
              getMp4Files(file.path);
          }
        });
      }
    });
  }

  Widget showThumbnailVideo(path) {
    return FutureBuilder(
      future: _getThumbnail(path),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.red,
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 30,
            )
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[300],
            child: loading(),
          );
        }
      },
    );
  }

  playVideo(fil) {
    Get.toNamed('/video-player', arguments: fil);
  }

  _getThumbnail(path) async {
    final Completer completer = Completer();
    Uint8List? bytes = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    final image = Image.memory(bytes!,fit: BoxFit.fitWidth,);
    image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(image);
    }));
    return completer.future;
  }

  shareVideo(fil) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Share.shareFiles([fil], text: 'This video is share from ${packageInfo.appName} app, \n\n download now at https://play.google.com/store/apps/details?id=${packageInfo.packageName}');
  }

  deleteVideo(fil) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete video'),
          content: const Text('Are you sure want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () =>Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                File(fil).deleteSync(recursive: true);
                files.removeAt(files.indexOf(fil));
                Get.back();
                if (Get.currentRoute == '/video-player') {
                  Get.back();
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}