import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:webapp/SmartFolder.dart';
import 'package:webapp/application.dart';
import 'package:webapp/constants.dart';
import 'package:webapp/init.dart';
import 'package:webapp/logger.dart';
import 'package:webapp/utils.dart';
import 'package:webviewx/webviewx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await preProcess();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebApp',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late WebViewXController webviewController;
  late FocusNode webUrlFocusNode;
  late TextEditingController webUrlController;
  late final AppController global;
  final double statusBarHeight = 25;
  final double suggestTitleHeight = Application.isTinyDevice ? 16 : 50;
  final double suggestFontSize = Application.isTinyDevice ? 12 : 24;
  final double suggestSpacing = Application.isTinyDevice ? 2 : 8;
  final double downloadIconSize = Application.isTinyDevice ? 12 : 28;
  final double minBookCoverWidth = Application.isTinyDevice ? 30 : 60;
  final double topBarButtonSize = Application.isTinyDevice ? 12 : 24;
  final TextStyle suggestStyle = Application.isTinyDevice
      ? const TextStyle(fontSize: 7, color: Colors.black87)
      : const TextStyle(fontSize: 12, color: Colors.black87);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Gradient normalButtonGradient = const RadialGradient(
      colors: [Color(0xFF80CBC4), Color(0xFF009688)],
      center: Alignment.topRight,
      radius: 3);
  Gradient licenceTextGradient = const LinearGradient(
    colors: [Color(0xFF80CBC4), Color(0xFF009688), Color(0xFF80CBC4)],
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
    // setRotateMode();
    global = Get.find();

    webUrlFocusNode = FocusNode();
    webUrlController = TextEditingController();
    webUrlController.text = global.webUrl.value;
  }

  @override
  void didChangeMetrics() {
    setState(() {
      Application.screenSize = Size(
          WidgetsBinding.instance!.window.physicalSize.width /
              Application.devicePixelRatio,
          WidgetsBinding.instance!.window.physicalSize.height /
              Application.devicePixelRatio);

      logger.fine("screenSize:${Application.screenSize}");
    });
  }

  @override
  void dispose() {
    webviewController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Application.screenSize = MediaQuery.of(context).size;
    Application.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return WillPopScope(
        onWillPop: () async {
          webviewController.goBack();
          return false;
        },
        child: Scaffold(
          key: scaffoldKey,
          body: Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Container(
                  height: statusBarHeight,
                  color: Colors.transparent,
                ),
                Expanded(
                  child: WebViewX(
                      height: Application.screenSize.height,
                      width: Application.screenSize.width,
                      initialSourceType: SourceType.url,
                      onWebViewCreated: (controller) {
                        controller.loadContent(
                            global.webUrl.value, SourceType.url);
                        webviewController = controller;
                      },
                      onWebResourceError: (error) {
                        largePrint(
                            "Url = ${error.failingUrl} Error = [${error.description}, ${error.errorCode}, ${error.errorType}]");
                        switch (error.errorCode) {
                          case -10:
                            // Navigator.pop(context);
                            webviewController.goBack();
                            break;
                          case -6:
                          default:
                            scaffoldKey.currentState?.openDrawer();
                            break;
                        }
                      },
                      onPageStarted: (msg) {
                        logger.fine("onPageStarted HTML:$msg");
                      },
                      onPageFinished: (msg) async{
                        logger.fine("onPageFinished HTML:$msg");
                        if(msg.compareTo("about:blank")!=0) {
                          logger.fine("Title:${await webviewController.getTitle()}");
                        }
                      },
                  )
                ),
              ],
            ),
          ),
          drawer: Container(
              padding: const EdgeInsets.all(0),
              width: Application.screenSize.width - 50,
              color: Colors.white70,
              child: Column(
                children: [
                  Container(
                    height: statusBarHeight,
                  ),
                  Card(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: SmartFolder(
                        onExpansionChanged: (e) {
                          if (e) {
                            FocusScope.of(context)
                                .requestFocus(webUrlFocusNode);
                          } else {
                            // webUrlFocusNode.unfocus();
                          }
                        },
                        initiallyExpanded: true,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: const ListTile(
                            leading: Icon(
                              LineAwesomeIcons.app_net,
                              size: 32,
                            ),
                            dense: true,
                            title: Text(
                              "网甲套装",
                            ),
                          ),
                        ),
                        children: [
                          const Divider(
                            thickness: 1.0,
                          ),
                          TextField(
                            controller: webUrlController,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                            focusNode: webUrlFocusNode,
                            decoration: InputDecoration(
                              labelText: "Url",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.8)),
                              hintText: "http://www.baidu.com:80",
                              suffixIcon: IconButton(
                                alignment: Alignment.center,
                                icon: const Icon(Icons.check),
                                onPressed: () =>
                                    toNewUrl(webUrlController.text.trim()),
                              ),
                            ),
                            // autofocus: true,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () =>
                                toNewUrl(webUrlController.text.trim()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: suggestTitleHeight,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "曾用网址：",
                      style: TextStyle(fontSize: suggestFontSize),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Wrap(
                    spacing: suggestSpacing,
                    runSpacing: suggestSpacing,
                    runAlignment: WrapAlignment.start,
                    children: Application.hostHistory.map((childNode) {
                      return GradientElevatedButton(
                          onPressed: () {
                            webUrlController.text = childNode;
                            toNewUrl(childNode);
                          },
                          gradient: normalButtonGradient,
                          style: OutlinedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)))),
                          child: Text(
                            childNode,
                            style: suggestStyle,
                          ));
                    }).toList(),
                  ),
                  Card(
                      child: Container(
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LineAwesomeIcons.door_open),
                          Text("退出"),
                        ],
                      ),
                      onPressed: () => exit(0),
                    ),
                  )),
                  Container(
                      alignment: Alignment.center,
                      child: Obx(() {
                        return GradientText(
                            "网页飞行套装 -- Ver ${global.version} -- Power by Olgeer.",
                            gradient: licenceTextGradient);
                      })),
                ],
              )),
          // onEndDrawerChanged: (v)=>webUrlFocusNode.unfocus(),
        ));
  }

  void toNewUrl(String url) {
    logger.info(url);
    global.webUrl = url.obs;
    webviewController.loadContent(url, SourceType.url);
    Application.cache.write(WebUrlTag, url);

    if (Application.hostHistory.contains(url)) {
      Application.hostHistory.remove(url);
    }
    if (Application.hostHistory.length > hostHistorySize) {
      Application.hostHistory.removeLast();
    }
    Application.hostHistory.insert(0, url);
    Application.cache
        .write(HostHistoryTag, jsonEncode(Application.hostHistory));

    Navigator.pop(context);
  }
}
