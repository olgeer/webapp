import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:webapp/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:hash/hash.dart' as hash;
import 'package:path/path.dart' as p;
import 'package:webapp/application.dart';
import 'package:r_upgrade/r_upgrade.dart';

String genKey({int lenght = 24}) {
  const randomChars = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String key = "";
  for (int i = 0; i < lenght; i++) {
    key += randomChars[Random().nextInt(randomChars.length)];
  }
  return key;
}

String str2hex(String str) {
  const hex2char = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String hexStr = "";
  // if (str != null) {
    for (int i = 0; i < str.length; i++) {
      int ch = str.codeUnitAt(i);
      hexStr += hex2char[(ch & 0xF0) >> 4];
      hexStr += hex2char[ch & 0x0F];
//      logger.fine("hexStr:[$hexStr]");
    }
  // } else {
  //   throw new Exception("Param string is null");
  // }
  return hexStr;
}

String Uint8List2HexStr(Uint8List uint8list) {
  const hex2char = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String hexStr = "";
  // if (uint8list != null) {
    for (int i in uint8list) {
      hexStr += hex2char[(i & 0xF0) >> 4];
      hexStr += hex2char[i & 0x0F];
    }
  // } else {
  //   throw new Exception("Param Uint8List is null");
  // }
  return hexStr;
}

String? size2human(double size) {
  String unit;
  double s = size;
  if (size != -1) {
    int l;
    if (size < 1024) {
      l = 0;
    } else if (size < 1024 * 1024) {
      l = 1;
      s = size / 1024;
    } else {
      for (l = 2; size >= 1024 * 1024; l++) {
        size = size / 1024;
        if ((size / 1024) < 1024) {
          s = size / 1024;
          break;
        }
      }
    }

    switch (l) {
      case 0:
        unit = "Byte";
        break;
      case 1:
        unit = "KB";
        break;
      case 2:
        unit = "MB";
        break;
      case 3:
        unit = "GB";
        break;
      case 4:
        //不可能也不该达到的值
        unit = "TB";
        break;
      default:
        //ER代表错误
        unit = "ER";
    }

    String format = s.toStringAsFixed(1);
    return format + unit;
  }
  return null;
}

String getFileName(String path) {
  // var paths = path.split("/");
  // return paths[paths.length - 1];
  return p.basenameWithoutExtension(path);
}

String getFullFileName(String path) {
  return p.basename(path);
}

String getFileExtname(String path) {
  // var paths = path.split("/");
  // var filenames = paths[paths.length - 1].split(".");
  // return filenames[filenames.length - 1];
  return p.extension(path);
}

String? readFileString(String filepath) {
  File readFile = File(filepath);
  if (readFile.existsSync()) {
    return readFile.readAsStringSync(encoding: Utf8Codec());
  }
  return null;
}

void writeFileString(String filepath, String contents) {
  File writeFile = File(filepath);
  if (!writeFile.existsSync()) {
    writeFile.createSync(recursive: true);
  }
  writeFile.writeAsStringSync(contents);
  logger.fine( "New file = ${writeFile.path}");
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
String dateTime() => DateTime.now().toString();
int nowInt() => DateTime.now().millisecondsSinceEpoch;

String? sha512(String filePath) {
  File orgFile = File(filePath);
  if (!orgFile.existsSync()) return null;

  Uint8List orgBytes = orgFile.readAsBytesSync();
  Uint8List shaBytes = hash.SHA512().update(orgBytes).digest();
  // logger.fine("sha512($filePath)=[${shaBytes.toString()}]");
  return Uint8List2HexStr(shaBytes);
}

List<String> objectListToStringList(List<dynamic> listObject) {
  List<String> newListString = [];
  for (dynamic obj in listObject) {
    newListString.add(obj.toString());
  }
  return newListString;
}

String? md5(String? str) {
  if (str == null) return null;
  Uint8List md5Bytes = hash.MD5().update(str.codeUnits).digest();
  //logger.fine("md5($str)=${md5Bytes}");
  return Uint8List2HexStr(md5Bytes);
}

void largePrint(dynamic msg) {
  String str;
  final int maxPrintLenght = 511;

  if (!(msg is String)) {
    str = msg.toString();
  } else {
    str = msg;
  }

  for (String oneLine in str.split("\n")) {
    while (oneLine.length > maxPrintLenght) {
      print(oneLine.substring(0, maxPrintLenght));
      oneLine = oneLine.substring(maxPrintLenght);
    }
    print(oneLine);
  }
}

void largeDebug(dynamic msg) {
  String str;
  final int maxPrintLenght = 511;

  if (!(msg is String)) {
    str = msg.toString();
  } else {
    str = msg;
  }

  for (String oneLine in str.split("\n")) {
    while (oneLine.length > maxPrintLenght) {
      logger.fine( oneLine.substring(0, maxPrintLenght));
      oneLine = oneLine.substring(maxPrintLenght);
    }
    logger.fine( oneLine);
  }
}

String double2percent(double d) =>
    ((d * 10000).floor() / 100).toStringAsFixed(2);

///设置屏幕旋转使能状态
void setRotateMode({bool canRotate = true}) {
  if (canRotate) {
    AutoOrientation.fullAutoMode();
  } else {
    AutoOrientation.portraitUpMode();
  }
  // Logger().debug("NovelReader", "canRotate:$canRotate");
}

Future<Response?> getUrlFile(String url,
    {int retry = 3, int seconds = 3}) async {
  Response? tmp;

  do {
    try {
      tmp = await HttpUtils.getForFullResponse(url);
    } catch (e) {
      print("get file error:$e");
      await Future.delayed(Duration(seconds: seconds));
    }
  } while ((tmp == null || tmp.statusCode != 200) && --retry > 0);

  return tmp?.statusCode == 200 ? tmp : null;
}

Future<String?> saveUrlFile(String url,
    {String? saveFileWithoutExt, int retry = 3, int seconds = 3}) async {
  Response? tmpResp = await getUrlFile(url, retry: retry, seconds: seconds);
  // largePrint(tmpResp.headers);
  // if(tmpResp!=null && tmpResp.headers['Content-Length']!=null && int.parse(tmpResp.headers['Content-Length'])>0) {
  if (tmpResp != null) {
    if (tmpResp.bodyBytes.length > 0) {
      List<String> tmpSpile = url.split("//")[1].split("/");
      String fileExt;
      if (tmpSpile.last.length > 0 && tmpSpile.last.split(".").length > 1) {
        if (saveFileWithoutExt == null || saveFileWithoutExt.length == 0) {
          saveFileWithoutExt =
              Application.appRootPath + "/" + tmpSpile.last.split(".")[0];
        }
        fileExt = tmpSpile.last.split(".")[1];
      } else {
        if (saveFileWithoutExt == null || saveFileWithoutExt.length == 0) {
          saveFileWithoutExt = genKey(lenght: 12);
        }
        fileExt = tmpResp.headers['Content-Type']?.split("/")[1]??"unknow";
      }

      File urlFile = File("$saveFileWithoutExt.$fileExt");
      if (urlFile.existsSync()) urlFile.deleteSync();
      urlFile.createSync(recursive: true);
      urlFile.writeAsBytesSync(tmpResp.bodyBytes.toList(),
          mode: FileMode.write, flush: true);
      return urlFile.path;
    }
  }
  return null;
}

String save2File(String filePath, String content) {
  File saveFile = File(filePath);

  if (saveFile.existsSync()) saveFile.deleteSync();
  saveFile.createSync(recursive: true);

  saveFile.writeAsStringSync(content,
      mode: FileMode.write, flush: true, encoding: Utf8Codec());
  return saveFile.path;
}

String? read4File(String filePath) {
  File readFile = File(filePath);
  if (readFile.existsSync()) {
    try {
      return readFile.readAsStringSync();
    } catch (e) {
      return null;
    }
  } else
    return null;
}

bool fileRename(String beforeName, String afterName) {
  File beforeFile = File(beforeName);
  // logger.fine( "Ready rename\n$beforeName\n to \n$afterName");
  if (beforeFile.existsSync()) {
    beforeFile.renameSync(afterName);
    logger.fine( "Renamed\n$beforeName\n to \n$afterName");
    return true;
  }
  return false;
}

String str2Regexp(String str) {
  final List<String> encode = [
    '.',
    '\\',
    '(',
    ')',
    '[',
    ']',
    '+',
    '*',
    '^',
    '\$',
    '?',
    '{',
    '}',
    '|',
    '-',
  ];
  String tmp = "";

  for (int i = 0; i < str.length; i++) {
    String c = str.substring(i, i + 1);
    for (String s in encode) {
      if (s.compareTo(c) == 0) {
        tmp += '\\';
        break;
      }
    }
    tmp += c;
  }
  // for(String s in encode){
  //   tmp=tmp.replaceAll(s, '\\'+s);
  // }
  return tmp;
}

String? fixJsonFormat(String? json) {
  return json?.replaceAll("\\", "\\\\");
}

Future<void> upgradeApk(String url,{String? fileName})async{
  await RUpgrade.upgrade(
      url,fileName: fileName, isAutoRequestInstall: true,useDownloadManager: true);
}

String languageCode2Text(String code) {
  Map<String, String> transMap = {"zh": "中文", "en": "English"};
  return transMap[code]??"中文";
}

bool isWorkday(DateTime now) {
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)
    return false;
  return true;
}

String int2Str(int value, {int width = 2}) {
  String s = value.toString();
  for (int i = 0; i < (width - s.length); i++) {
    s = "0" + s;
  }
  return s;
}

int rgbCalc(int value, int change) {
  int t = value + change;
  if (t < 0) t = 0;
  if (t > 255) t = 255;
  return t;
}

Color shade(Color originColor, int level) {
  return Color.fromARGB(
      originColor.alpha,
      rgbCalc(originColor.red, level * 30),
      rgbCalc(originColor.green, level * 30),
      rgbCalc(originColor.blue, level * 30));
}

String? filterWebDescribe(String? html) {
  if(html==null)return null;
  return html
      .replaceAll("&nbsp;", " ")
      .replaceAll(RegExp('<(\\S*?)>[^<]*</\\1>'), "")
      .replaceAll(RegExp('<[^>]*>'), "")
      .replaceAll("\r", "")
      .replaceAll("\n", "")
      .trim();
}

String filterWebText(String html) {
  return html
      .replaceAll("&nbsp;", " ")
      .replaceAll(RegExp('<(\\S*?)>[^<]*</\\1>'), "")
      .replaceAll(RegExp('<[^>]*>'), "")
      .replaceAll("\r", "")
      // .replaceAll("\n", "")
      .trim();
}

typedef FutureCall = Future<Response> Function();
Future<Response?> call(
    {int retryTimes: 3, int seconds = 2, required FutureCall retryCall}) async {
  Response? resp;
  do {
    retryTimes--;
    try {
      resp = await retryCall();
      //await Future.delayed(Duration(milliseconds: downloadSleepDuration));
    } catch (e) {
      print("Response error[$retryTimes]:$e");
      await Future.delayed(Duration(seconds: seconds));
    }
  } while (resp == null && retryTimes > 0);
  return resp;
}

enum RequestMethod { get, post }

Future<String?> getHtml(String? sUrl,
    {Map<String, String>? headers,
    Map<String, String>? queryParameters,
    String? body,
    RequestMethod method = RequestMethod.get,
    Encoding encoding = utf8,
    int retryTimes = 3,
    int seconds = 5,
    String? debugId}) async {
  String? html;
  // Logger().debug("getHtml-[${debugId ?? ""}]", "Ready getHtml: [$sUrl]");
  if (sUrl != null) {
    Response? listResp = await call(
        seconds: seconds,
        retryTimes: retryTimes,
        retryCall: () async {
          try {
            if (method == RequestMethod.get) {
              return await HttpUtils.getForFullResponse(sUrl,
                  queryParameters: queryParameters, headers: headers);
            } else {
              return await HttpUtils.postForFullResponse(sUrl,
                  queryParameters: queryParameters,
                  headers: headers,
                  body: body);
            }
          } catch (e) {
            if (e is HttpResponseException && int.parse(e.statusCode) == 302) {
              String newUrl = "${getDomain(sUrl)}${e.headers!["location"]}";
              // print("status code:302 and redirect to $newUrl");
              return await HttpUtils.getForFullResponse(newUrl);
            } else
              throw e;
          }
        });

    if (listResp!=null && listResp.statusCode == 200) {
      try {
        html = encoding.decode(listResp.bodyBytes);
      } catch (e) {
        // if(encoding.name.contains("gb") && isPhone()){
        //   html = await CharsetConverter.decode("GB18030",listResp.bodyBytes);
        // }else{
          print("Response error[$retryTimes]:$e");
          return null;
        // }
      }
    }
  }
  return html;
}

String getDomain(String url) {
  return url.replaceAll(url.split("/").last, "");
}

String? fixedLength(String? str, int maxLength,
    {String expandAlert = " ……",
    String collapseAlert = " 收起",
    bool expandState = false}) {

  if (str != null) {
    if (str.length > maxLength) {
      if(expandState) {
        return "$str$collapseAlert";
      }else{
        return "${str.substring(0, str.length > maxLength ? maxLength : str.length)}$expandAlert";
      }
    } else
      return str;
  } else
    return null;
}

String filterScript(String html) {
  int filterStart = 0, scriptLocal, scriptEnd;
  String filtedHtml = html;
  do {
    scriptLocal = filtedHtml.indexOf("<script", filterStart);
    if (scriptLocal > 0) {
      scriptEnd = filtedHtml.indexOf("</script>", scriptLocal);
      filtedHtml = filtedHtml.substring(0, scriptLocal) +
          filtedHtml.substring(scriptEnd + 9, filtedHtml.length);
      filterStart = scriptLocal;
    }
  } while (scriptLocal > 0);
  largeLog(filtedHtml);
  return filtedHtml;
}

///按separate长度等分字符串，多出的放结尾
///如：split("abcdefg",3)，结果数组为["abc","def","g"]
List<String> split(String? srcStr, int separate) {
  if (srcStr == null || separate <= 0) return [];

  List<String> splits = [];

  int one = srcStr.length ~/ separate;
  for (int n = 0; n < separate; n++) {
    splits.add(srcStr.substring(n * one, (n + 1) * one));
  }
  if (srcStr.length % separate > 0)
    splits.add(srcStr.substring(separate * one));
  else
    splits.add("");

  return splits;
}

///合并字符串数组为字符串
///如：concat(["a","b","c"])，结果为"abc"
///当参数separate有值时，会在每个合并串中间插入separate
String concat(List<String?> splits, {String separate=""}) {
  String retStr = "";
  for (int p = 0; p < splits.length; p++) {
    if (splits[p] != null) retStr += splits[p]!;
    if (p < splits.length - 1) retStr += separate;
  }
  return retStr;
}

bool isMobile(String phone) {
  final RegExp exp = RegExp(
      r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');

  return exp.hasMatch(phone);
}

bool isDigit(String number, {int min = 1, int max = 16}) {
  assert(min > 0 && max > 0);
  assert(max >= min);

  RegExp exp = RegExp(
      '^[1-9]\\d{' + (min - 1).toString() + ',' + (max - 1).toString() + '}\$');

  return exp.hasMatch(number);
}

bool isDigitAndChar(String verifyStr, {int min = 1, int max = 16}) {
  assert(min > 0 && max > 0);
  assert(max >= min);

  RegExp exp =
  RegExp('^[\\d|\\w]{' + min.toString() + ',' + max.toString() + '}\$');

  return exp.hasMatch(verifyStr);
}

bool isPassword(String psw, {int min = 8, int max = 16}) {
  assert(min > 0 && max > 0);
  assert(max >= min);

  RegExp exp =
  // RegExp('^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{' + min.toString() + ',' + max.toString() + '}\$');
  RegExp('^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z]{' +
      min.toString() +
      ',' +
      max.toString() +
      '}\$');

  return exp.hasMatch(psw);
}

String encode(String value, String magic) {
  List<int> valueBytes = value.codeUnits;
  List<int> magicBytes = magic.codeUnits;
  List<int> tempBytes=[];

  for (int i = 0; i < valueBytes.length; i++) {
    tempBytes.add(valueBytes[i] ^ magicBytes[i % magicBytes.length]);
  }
  return base64.encode(tempBytes);
}

String decode(String value, String magic) {
  List<int> magicBytes = magic.codeUnits;
  List<int> valueBytes = base64.decode(value);
  List<int> tempBytes=[];

  for (int i = 0; i < valueBytes.length; i++) {
    tempBytes.add(valueBytes[i] ^ magicBytes[i % magicBytes.length]);
  }
  return utf8.decode(tempBytes);
}

List<int> objectListToIntegerList(List<dynamic> listObject) {
  List<int> newListString = [];
  for (dynamic obj in listObject) {
    newListString.add(obj.index);
  }
  return newListString;
}

bool compareGesture(List<int> first, List<int> second) {
  if (first.length != second.length) return false;
  for (int i = 0; i < first.length; i++) {
    if (first[i] != second[i]) return false;
  }
  return true;
}