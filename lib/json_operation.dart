import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

//读取Json文件
Future<Map<String, dynamic>> loadJson(String filePath) async {
  try {
    String jsonString = await rootBundle.loadString(filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  } catch (e) {
    return {};
  }
}
