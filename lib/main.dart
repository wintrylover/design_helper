import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

import 'read_json.dart';
import 'collapsible_sidebar.dart';
import 'title_bar.dart';
import 'add_page.dart';
import 'show_page.dart';

// 主程序入口
void main() async {
  // 读取配置文件
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FutureBuilder<Map<String, dynamic>>(
      future: loadJson('assets/config.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyApp(configJson: snapshot.data);
        } else {
          return MaterialApp(home: Scaffold(body: Center(child: Text("错误：${snapshot.error}"))));
        }
      },
    ),
  );

  // 无边框APP窗口
  doWhenWindowReady(() {
    appWindow.minSize = Size(950, 500);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

// 主应用程序
class MyApp extends StatelessWidget {
  final Map<String, dynamic>? configJson;

  const MyApp({super.key, required this.configJson});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design Helper',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: MyHomePage(configJson: configJson),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 主页面
class MyHomePage extends StatefulWidget {
  final Map<String, dynamic>? configJson;

  const MyHomePage({super.key, required this.configJson});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? defaultLibraryJson;
  Map<String, dynamic>? userLibraryJson;
  Map<String, dynamic> filesJson = {};
  bool loadJsonFinish = false;

  // 加载libraryJson并读取所有文件的info.json，同时判断文件的完整性
  Future<void> _loadFilesConfig() async {
    defaultLibraryJson = await loadJson('library/default library.json');
    userLibraryJson = await loadJson('library/user library.json');
    for (Map<String, dynamic> mainCategoryValue in defaultLibraryJson!.values) {
      for (Map<String, dynamic> subCategoryValue in mainCategoryValue['files'].values) {
        for (String md5Hash in subCategoryValue['subfiles'].keys) {
          filesJson[md5Hash] = await loadJson('library/default/$md5Hash/info.json');
        }
        // TODO: 文件完整性验证
        for (String filename in subCategoryValue['subfiles'].values) {
          File file = File('library/default/$filename/info.json');
          if (!await file.exists()) {}
        }
      }
    }
    for (Map<String, dynamic> mainCategoryValue in userLibraryJson!.values) {
      for (Map<String, dynamic> subCategoryValue in mainCategoryValue['files'].values) {
        for (String md5Hash in subCategoryValue['subfiles'].keys) {
          filesJson[md5Hash] = await loadJson('library/user/$md5Hash/info.json');
        }
        // TODO: 文件完整性验证
        for (String filename in subCategoryValue['subfiles'].values) {
          File file = File('library/user/$filename/info.json');
          if (!await file.exists()) {}
        }
      }
    }
    // 异步加载完成
    setState(() {
      loadJsonFinish = defaultLibraryJson!.isNotEmpty && userLibraryJson!.isNotEmpty && filesJson.isNotEmpty;
    });
  }

  // 初始化
  @override
  void initState() {
    super.initState();
    _loadFilesConfig();
  }

  // 回调函数，用于切换页面
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 回调函数，用于更新libraryJson
  void _updateLibraryJson(Map<String, dynamic> newLibraryJson, Map<String, dynamic> newFilesJson, bool user) {
    setState(() {
      if (!user) {
        defaultLibraryJson = newLibraryJson;
        filesJson = newFilesJson;
      } else {
        userLibraryJson = newLibraryJson;
        filesJson = newFilesJson;
      }
    });
    _saveLibraryJson(user);
  }

  // 保存更新后的libraryJson
  Future _saveLibraryJson(bool user) async {
    if (!user) {
      final libraryFile = File('library/default library.json');
      await libraryFile.writeAsString(json.encode(defaultLibraryJson));
    } else {
      final libraryFile = File('library/user library.json');
      await libraryFile.writeAsString(json.encode(userLibraryJson));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CollapsibleSidebar(configJson: widget.configJson, onItemTapped: _onItemTapped),
          Expanded(
            child: Column(children: [MyCustomTitleBar(), Expanded(child: _buildMainContentPage(_selectedIndex))]),
          ),
        ],
      ),
    );
  }

  // 根据索引显示不同的Page
  Widget _buildMainContentPage(int index) {
    switch (index) {
      case 0:
        if (loadJsonFinish) {
          return ShowPage(
            mainCategory: 'calculationSheets',
            defaultLibraryJson: defaultLibraryJson,
            userLibraryJson: userLibraryJson,
            filesJson: filesJson,
          );
        } else {
          return Center(child: Text('加载中...'));
        }
      case 1:
      case 5:
        return AddPage(
          defaultLibraryJson: defaultLibraryJson,
          userLibraryJson: userLibraryJson,
          filesJson: filesJson,
          onLibraryJsonChanged: _updateLibraryJson,
        );
      default:
        return Center(child: Text('页面$index'));
    }
  }
}
