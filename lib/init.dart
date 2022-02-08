import 'dart:convert';
import 'dart:io';

import 'package:base_utility/base_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webapp/application.dart';
import 'package:webapp/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

//App启动前预处理
Future<void> preProcess() async {
  await GetStorage.init();

  if (GetPlatform.isMobile) {
    var r = await [
      Permission.storage,
      Permission.notification,
      Permission.phone,
      Permission.camera,
    ].request();
    for (Permission k in r.keys) {
      logger.fine("${k.toString()}:${await k.status.isGranted}");
    }
  }

  await initPath();

  // Application.cache = await SharedPreferences.getInstance();
  Application.cache = GetStorage();
  AppController global = Get.put(AppController());
  Application.webUrl=Application.cache.read(WebUrlTag)??"http://olgeer.3322.org:14080";
  Application.showTopStateBar=Application.cache.read(ShowStateBarTag)??false;

  initLogger();

  Application.screenSize = loadScreenSize();

  //vibrate init
  Vibrate.init();

  //初始化闪光灯
  if (await FlashLamp.init()) {
    FlashLamp.useLamp = Application.cache.read(UseLampTag) ?? true;
    Application.useLamp = FlashLamp.useLamp;
  } else {
    Application.useLamp = false;
  }

  Application.keepWake = Application.cache.read(KeepWakeTag) ?? false;
  global.testMode.value = Application.cache.read(TestModeTag) ?? false;
  Application.canRotate = Application.cache.read(CanRotateTag) ?? false;
  Application.oledAntiBurn =
      Application.cache.read(OledAntiBurnTag) ?? false;
  Application.showIntro = Application.cache.read(ShowIntroTag) ?? true;
  Application.hostHistory=List.castFrom(jsonDecode(Application.cache.read(HostHistoryTag)??"[]"));

  //正式使用
  // Application.account =await Account.newInstance();

  // global.version=(await getAppVersion()).obs;

  ///不使用await，确保无网络时不影响离线使用
  delayLoad();

}

Future<void> initPath() async {
  Directory? tempDir = Platform.isIOS
      ? await getLibraryDirectory()
      : Platform.isAndroid
          ? await getExternalStorageDirectory()
          : Platform.isMacOS
              ? await getDownloadsDirectory()
              : null;
  Application.appRootPath = tempDir?.path ?? "/";
}

Future<void> delayLoad() async {
  // await Setting.loadSetting();
  // dio.Dio d=dio.Dio();
  // dio.Response resp = await d.post("http://olgeer.3322.org:8888/mirror.json");
  // logger.fine(resp.data.toString());
  getAppVersion();
}

Size loadScreenSize() {
  return Size(Application.cache.read(ScreenSizeHeightTag) ?? 0,
      Application.cache.read(ScreenSizeWidthTag) ?? 0);
}

Future<String> getAppVersion()async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // await 5.delay();
  AppController g=Get.find();
  g.version.value=packageInfo.version;
  // String appName = packageInfo.appName;
  // String packageName = packageInfo.packageName;
  // String version = packageInfo.version;
  // String buildNumber = packageInfo.buildNumber;
  // logger.fine("appName=$appName packageName=$packageName appversion=$version buildNumber:$buildNumber");
  // Application.appVersion = packageInfo.version;
  // Application.packageName = packageInfo.packageName;
  return packageInfo.version;
}