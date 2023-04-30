import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FolderController.dart';

class Folder extends StatelessWidget {
  Folder({Key? key}) : super(key: key);
  final ctrl = Get.put(FolderController());
   @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            title: Text(Get.arguments.split('/').last.split('/').first),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.blue],
                ),
              ),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    ctrl.loadImported();
                    Future.delayed(const Duration(seconds: 2), () => Get.back());
                  }),
            ]
          ),
          body: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ctrl.ctrlAds.showNativeAds(120),
                const SizedBox(height: 10),
                Expanded(
                    child: Obx(() => ctrl.files.isEmpty
                        ? const Center(child: Text('No Video imported yet !'))
                        : GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: ctrl.files.length,
                          itemBuilder: (context, index) {
                          var files = ctrl.files.reversed.toList();
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[900],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(child:ctrl.showThumbnailVideo(files[index])),
                                        Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => ctrl.playVideo(files[index]),
                                              borderRadius: BorderRadius.circular(10),
                                              onLongPress: () => ctrl.shareVideo(files[index]),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              files[index].split('/').last.split('.mp4').first ?? '',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        onPressed: () => ctrl.playVideo(files[index]),
                                        icon: const Icon(Icons.play_arrow,color: Colors.white,),
                                      ),
                                      IconButton(
                                        onPressed: () => ctrl.shareVideo(files[index]),
                                        icon: const Icon(Icons.share,color: Colors.white,),
                                      ),
                                      IconButton(
                                        onPressed: () => ctrl.deleteVideo(files[index]),
                                        icon: const Icon(Icons.delete,color: Colors.white,),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )))
              ],
            ),
          ),
        ));
  }
}
