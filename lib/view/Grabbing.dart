import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widget/Function.dart';
import '../controller/GrabbingController.dart';

class Grabbing extends StatelessWidget {
  Grabbing({Key? key}) : super(key: key);
  final ctrl = Get.put(GrabbingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Get.arguments.split('/').last.toString().capitalizeFirst} Downloader"),
        actions: [
          IconButton(
            onPressed: () {
              openUrl('http://192.168.100.146/video-downloader/help.php?p=${Get.arguments.split('/').last.toString()}');
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.orangeAccent],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/downloaded'),
          child: const Icon(Icons.folder_copy)),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(fontSize: 16),
                              autofocus: false,
                              keyboardType: TextInputType.url,
                              controller: ctrl.textController,
                              onSubmitted: (value) {
                                ctrl.search();
                                FocusScope.of(context).unfocus();
                              },
                              decoration: InputDecoration(
                                hintText: 'Paste link here',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                              onPressed: () => ctrl.search(),
                              icon: const Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: () => ctrl.pasteFromClipboard(Get.arguments.split('/').last),
                                icon: const Icon(
                                  Icons.paste,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  ctrl.textController.clear();
                                  ctrl.isLoading.value = false;
                                  ctrl.listData.clear();
                                  Get.appUpdate();
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  ctrl.ctrlAds.showNativeAds(120),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.withOpacity(0.2),
                    child: Obx(() {
                      if (ctrl.isLoading.value) {
                        return loading();
                      } else {
                        if (ctrl.listData.isEmpty) {
                          return const Center(child: Text('Content not found !'));
                        } else {
                          return Center(
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: Get.height / 2,
                                  width: Get.width,
                                  child: ctrl.thumbnailGenerate(ctrl.listData[0]),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 200,
                                  top: 0,
                                    child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.transparent,Colors.black],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )),
                                Positioned(
                                  left: 5,
                                  right: 5,
                                  bottom: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: ListView.builder(itemBuilder: (context, index) {
                                      return ElevatedButton(
                                            onPressed: () => ctrl.downloadVideo(ctrl.listData[index].url),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.download),
                                                Text(ctrl.listData[index].title, style: const TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis)),
                                              ],
                                            )
                                          );
                                        }, itemCount: ctrl.listData.length),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
