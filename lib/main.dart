import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

import 'json_operation.dart';
import 'collapsible_sidebar.dart';
import 'title_bar.dart';
import 'add_page.dart';

// 主程序入口
void main() async {
  // 读取配置文件并验证文件完整性
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([loadJson('assets/config.json'), loadJson('library/library.json')]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyApp(configJson: snapshot.data![0]);
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

  const MyHomePage({super.key, this.configJson});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CollapsibleSidebar(configJson: widget.configJson, onItemTapped: _onItemTapped),
          Expanded(
            child: Column(
              children: [
                MyCustomTitleBar(),
                Expanded(child: PageStorage(bucket: _pageStorageBucket, child: _buildMainContentPage(_selectedIndex))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //根据索引显示不同的Page
  Widget _buildMainContentPage(int index) {
    switch (index) {
      case 0:
        return Center(child: Text('主内容区域'));
      case 5:
        return AddPage(key: const PageStorageKey('add_Page'),);
        default:
        return Center(child: Text('页面$index'));
    }
  }
}
