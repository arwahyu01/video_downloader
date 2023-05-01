import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widget/Function.dart';
import '../controller/HomeController.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  final homeCtrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        openDialog();
        return Future(() => false);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Video Downloader'),
            titleSpacing: 0,
            leading: const Icon(Icons.download_for_offline_outlined, size: 30),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.blue],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => shareApp(),
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: () => reviewApp(),
                icon: const Icon(Icons.star),
              ),
              const SizedBox(width: 10),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed('/downloaded'),
            child: const Icon(Icons.folder_copy),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              homeCtrl.getListMenu();
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    homeCtrl.ctrlAds.showNativeAds(100),
                    const SizedBox(height: 10),
                    const Text('Download Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Obx(() {
                        return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
                          itemCount: homeCtrl.listMenu.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () => homeCtrl.goToPage(homeCtrl.listMenu[index].url),
                              child: Card(
                                elevation: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network('${homeCtrl.listMenu[index].icon}', width: 100, height: 100),
                                    const SizedBox(height: 10),
                                    Text(homeCtrl.listMenu[index].title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text(homeCtrl.listMenu[index].subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                )),
          )),
    );
  }

  void openDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openDialogRate();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
