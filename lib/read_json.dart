import 'dart:convert';
import 'dart:async';
import 'dart:io';

//读取Json文件
Future<Map<String, dynamic>> loadJson(String filePath) async {
  try {
    String jsonString = await File(filePath).readAsString();
    Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  } catch (e) {
    print(e);
    return {};
  }
}
