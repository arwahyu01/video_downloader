import 'dart:io';
import 'package:all_video_downloader/controller/DownloadedController.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'widget/Function.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  var url = Get.arguments;
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  int? buffer;
  final ctrl = Get.put(DownloadedController());

  @override
  void initState() {
    super.initState();
    initializePlayer();
    requestReviewApp();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Preview'),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        actions: [
          InkWell(
            onTap: () {
             reviewApp();
            },
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.white),
                Text('Rate Us', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.blue],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
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
              padding: const EdgeInsets.all(5),
              child: _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  ctrl.shareVideo(url.toString().replaceAll('file://', ''));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.share, color: Colors.white),
                      Text('Share', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              // full screen button
              InkWell(
                onTap: () {
                  _chewieController?.enterFullScreen();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fullscreen_outlined, color: Colors.white, size: 40),
                ),
              ),
              InkWell(
                onTap: () {
                  ctrl.deleteVideo(url.toString().replaceAll('file://', ''));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.white),
                      Text('Delete', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> initializePlayer() async {
    _controller = VideoPlayerController.file(
        File(url.toString().replaceAll('file://', '')));
    await Future.wait([
      _controller.initialize(),
    ]);
    createChewieController();
    setState(() {});
  }

  void createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      progressIndicatorDelay:
          buffer != null ? Duration(milliseconds: buffer!) : null,
      hideControlsTimer: const Duration(seconds: 1),
      allowFullScreen: true,
      allowMuting: true,
      aspectRatio: _controller.value.aspectRatio,
      showControls: true,
      fullScreenByDefault: false,
    );
  }
}
