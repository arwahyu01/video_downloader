import 'dart:math';
import 'package:applovin_max/applovin_max.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api.dart';

class AdsController extends GetxController with WidgetsBindingObserver {
  var isShowingAppOpenAd = false.obs;
  var appOpenIsLoaded = false.obs;

  bool isAppPaused = false;
  bool isInterstitialAdLoaded = false;
  int maxFailedLoadAttempts = 3;
  int interstitialLoadAttempts = 0;
  int interstitialRetryAttemptAppLovin = 0;
  InterstitialAd? interstitialAd;
  AppOpenAd? appOpenAd;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      isAppPaused = true;
    }
    if (state == AppLifecycleState.resumed && isAppPaused) {
      showAppOpenIfAvailable();
      isAppPaused = false;
    }
  }

  // Controller for handling ads ================================

  void createInterAds() {
    if (ApiService.typeAds.value == 'admob') {
      createAdmobInterstitial();
    } else if (ApiService.typeAds.value == 'facebook') {
      createFanInterstitialAd();
    } else if (ApiService.typeAds.value == 'applovin') {
      createAppLovinInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (ApiService.typeAds.value == 'admob') {
      showAdmobInterstitial();
    } else if (ApiService.typeAds.value == 'facebook') {
      showFanInterstitialAd();
    } else if (ApiService.typeAds.value == 'applovin') {
      showAppLovinInterstitialAd();
    }
  }

  showNativeAds(height) {
    if (ApiService.typeAds.value == 'admob') {
      return GetNativeAds(height: height);
    } else if (ApiService.typeAds.value == 'facebook') {
      return createFanNativeAds(height);
    } else {
      return Container();
    }
  }

  void loadAdOpen() {
    if (ApiService.typeAds.value == 'admob' || ApiService.typeAds.value == 'facebook') {
      admobAppOpen();
    } else if (ApiService.typeAds.value == 'applovin') {
      appLovinAppOpen();
    }else{
      admobAppOpen();
    }
  }

  void showAppOpenIfAvailable() async {
    if (ApiService.typeAds.value == 'admob' || ApiService.typeAds.value == 'facebook') {
      if (appOpenAd == null) {
        loadAdOpen();
        return;
      }
      if (isShowingAppOpenAd.value) return;

      appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => isShowingAppOpenAd.value = true,
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          isShowingAppOpenAd.value = false;
          appOpenAd = null;
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isShowingAppOpenAd.value = false;
          appOpenAd = null;
          loadAdOpen();
        },
      );
      appOpenAd!.show();
    } else if (ApiService.typeAds.value == 'applovin') {
      bool isReady = (await AppLovinMAX.isAppOpenAdReady(ApiService.adsUnitId['appopen_applovin']))!;
      if (isReady) {
        AppLovinMAX.showAppOpenAd(ApiService.adsUnitId['appopen_applovin'] ?? '');
      } else {
        AppLovinMAX.loadAppOpenAd(ApiService.adsUnitId['appopen_applovin'] ?? '');
      }
    }
  }

  // end Controller for handling ads ================================

  // ADMOB ================================

  void admobAppOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppOpenAd.load(
      adUnitId: prefs.getString('app_open') ?? ApiService.adsUnitId['app_open'] ?? '',
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          appOpenIsLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          appOpenAd = null;
          appOpenIsLoaded.value = false;
          appLovinAppOpen();
        },
      ),
    );
  }

  void createAdmobInterstitial() {
    InterstitialAd.load(
        adUnitId: ApiService.adsUnitId['interstitial_admob'] ?? '',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            interstitialLoadAttempts = 0;
            isInterstitialAdLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAd = null;
            interstitialLoadAttempts += 1;
            isInterstitialAdLoaded = false;
            if (interstitialLoadAttempts <= maxFailedLoadAttempts) {
              createAdmobInterstitial();
            } else {
              createFanInterstitialAd();
              interstitialLoadAttempts = 0;
            }
          },
        ));
  }

  void showAdmobInterstitial() {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          interstitialAd = null;
          createAdmobInterstitial();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          interstitialAd = null;
        },
      );
      interstitialAd!.show();
    } else {
      createFanInterstitialAd();
      Future.delayed(const Duration(seconds: 1), () {
        showFanInterstitialAd();
      });
    }
  }

  // end admob ================================

  // Facebook ========================================

  void createFanInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: ApiService.adsUnitId['interstitial_fan'] ?? '',
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          isInterstitialAdLoaded = true;
        }

        if (result == InterstitialAdResult.DISMISSED && value["invalidated"] == true) {
          interstitialLoadAttempts += 1;
          if (interstitialLoadAttempts <= maxFailedLoadAttempts) {
            isInterstitialAdLoaded = false;
            createFanInterstitialAd();
          } else {
            interstitialLoadAttempts = 0;
            createAdmobInterstitial();
          }
        }
      },
    );
  }

  void showFanInterstitialAd() {
    FacebookInterstitialAd.showInterstitialAd();
  }

  createFanNativeAds(height) {
    height = (height <= 300) ? 300 : height;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.blue[100]),
      child: FacebookNativeAd(
        placementId: ApiService.adsUnitId['native_fan'] ?? '',
        adType: NativeAdType.NATIVE_AD,
        width: double.infinity,
        height: height.toDouble(),
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        descriptionColor: Colors.white,
        buttonColor: Colors.deepPurple,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.white,
        listener: (result, value) {},
        keepExpandedWhileLoading: false,
        expandAnimationDuraion: 300,
      ),
    );
  }

// end facebook ========================================

// applovin ============================================
  void createAppLovinInterstitialAd() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        interstitialRetryAttemptAppLovin = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        interstitialRetryAttemptAppLovin = interstitialRetryAttemptAppLovin + 1;
        int retryDelay = pow(2, min(6, interstitialRetryAttemptAppLovin)).toInt();
        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(ApiService.adsUnitId['interstitial_applovin'] ?? '');
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    ));

    AppLovinMAX.loadInterstitial(ApiService.adsUnitId['interstitial_applovin'] ?? '');
  }

  Future<void> showAppLovinInterstitialAd() async {
    bool isReady = (await AppLovinMAX.isInterstitialReady(ApiService.adsUnitId['interstitial_applovin']))!;
    if (isReady) {
      AppLovinMAX.showInterstitial(ApiService.adsUnitId['interstitial_applovin'] ?? '');
    } else {
      createAppLovinInterstitialAd();
      Future.delayed(const Duration(seconds: 1), () {
        showAppLovinInterstitialAd();
      });
    }
  }

  void appLovinAppOpen() {
    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
      onAdLoadedCallback: (ad) {},
      onAdLoadFailedCallback: (adUnitId, error) {},
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        AppLovinMAX.loadAppOpenAd(ApiService.adsUnitId['appopen_applovin'] ?? '');
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        AppLovinMAX.loadAppOpenAd(ApiService.adsUnitId['appopen_applovin'] ?? '');
      },
      onAdRevenuePaidCallback: (ad) {},
    ));

    AppLovinMAX.loadAppOpenAd(ApiService.adsUnitId['appopen_applovin'] ?? '');
  }
}

class GetNativeAds extends StatefulWidget {
  const GetNativeAds({Key? key, required this.height}) : super(key: key);
  final int height;

  @override
  State<GetNativeAds> createState() => _GetNativeAdsState();
}

class _GetNativeAdsState extends State<GetNativeAds> {
  var isNativeLoaded = false.obs;
  var isFailed = false.obs;
  NativeAd? nativeAd;

  @override
  void initState() {
    super.initState();
    createAdmobNativeAds();
  }

  void createAdmobNativeAds() {
    NativeAd(
      adUnitId: ApiService.adsUnitId['native_admob'],
      factoryId: 'listTile',
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: widget.height <= 180 ?  TemplateType.small :  TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          isNativeLoaded.value = true;
          isFailed.value = false;
          nativeAd = ad as NativeAd;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          isNativeLoaded.value = false;
          isFailed.value = true;
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isNativeLoaded.value
          ? Container(
              height: widget.height.toDouble(),
              width: Get.height > Get.width ? Get.width : (Get.height * 0.3),
              padding: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration:  BoxDecoration(border: const Border.fromBorderSide(BorderSide(color: Colors.blue, width: 2)),color: Colors.grey[200]),
              child: AdWidget(ad: nativeAd!))
          : isFailed.value
              ? AdsController().createFanNativeAds(widget.height >= 300 ? widget.height : 300)
              : const Text('Loading ads ...'),
    );
  }
}
