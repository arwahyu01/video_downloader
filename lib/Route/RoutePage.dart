import 'package:get/get.dart';
import '../view/Grabbing.dart';
import '../view/Folder.dart';
import '../view/Downloaded.dart';
import '../view/VideoPlayer.dart';
import '../view/Maintenance.dart';
import '../view/SplashScreen.dart';
import '../view/Home.dart';

class RoutePage extends GetxController {
  static final page = [
    GetPage(name: '/home', page: () => Home(), transition: Transition.fadeIn),
    GetPage(name: '/maintenance', page: () => const Maintenance(), transition: Transition.fadeIn),
    GetPage(name: '/grab', page: () => Grabbing(), transition: Transition.fadeIn),
    GetPage(name: '/downloaded', page: () => Downloaded(), transition: Transition.fadeIn),
    GetPage(name: '/video-player', page: () => const Videos(), transition: Transition.zoom),
    GetPage(name: '/folder', page: () => Folder(), transition: Transition.fadeIn),
    GetPage(name: '/splashscreen', page: () => SplashScreen(), transition: Transition.zoom),
  ];
}