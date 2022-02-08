import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//全局变量
class Application {
  // static String appVersion="未知";
  // static String packageName="com.sword.webapp";

  static late GetStorage cache;
  static late String appRootPath;
  static bool isDark=false;
  static late Size screenSize;
  static late double devicePixelRatio;
  static late Map<String, dynamic> deviceInfo;
  static String? onlyCode;
  static bool isTinyDevice = false;
  static bool showTopStateBar=true;
  static List<String> hostHistory=[];

  ///系统屏幕旋转同步开关
  static bool canRotate = false;

  static bool useLamp = true;

  ///oled屏幕防烧屏开关
  static bool oledAntiBurn = true;

  ///是否关闭系统休眠
  static bool keepWake = true;

  ///曲面屏防误触开关
  static bool antiTouch = true;

  ///是否允许左右滑动控制翻页
  static bool useSwift = false;

  ///每次启动软件时只进行一次
  static bool isUpdated = false;

  static bool showIntro = true;
  static bool appCanUpgrade = false;
}

class AppController extends GetxController{
  var webUrl = "".obs;
  var logs = [].obs;
  var testMode = false.obs;
  var version = "未知".obs;

  addLog(String log){
    if(logs.length>1000)logs.removeAt(0);
    logs.add(log);
  }
  toggleTestMode()=>testMode.toggle();
  setWebUrl(String _webUrl)=> webUrl=_webUrl.obs;
}