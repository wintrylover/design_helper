import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// --- 自定义标题栏 Widget ---
class MyCustomTitleBar extends StatelessWidget {
  const MyCustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 定义标题栏背景色
    final titleBarColor = Colors.grey[200]; // 可以根据你的主题调整

    return Container(
      height: 40, // 标题栏高度
      color: titleBarColor,
      child: Row(
        children: [
          // --- 窗口拖动区域 ---
          Expanded(
            child: MoveWindow(
              // 可选: 在这里添加标题文本或 Logo
              // child: Align(
              //   alignment: Alignment.centerLeft,
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 16.0),
              //     child: Text("我的音乐应用", style: TextStyle(fontSize: 14)),
              //   ),
              // ),
            ),
          ),

          // --- 窗口控制按钮 ---
          MinimizeWindowButton(colors: buttonColors),
          MaximizeWindowButton(colors: buttonColors),
          CloseWindowButton(colors: closeButtonColors),
        ],
      ),
    );
  }
}

// --- 自定义窗口按钮颜色 (可选) ---
final buttonColors = WindowButtonColors(
  iconNormal: Colors.black54, // 正常图标颜色
  mouseOver: Colors.grey[400], // 鼠标悬停背景色
  mouseDown: Colors.grey[500], // 鼠标按下背景色
  iconMouseOver: Colors.black87, // 鼠标悬停图标颜色
  iconMouseDown: Colors.white, // 鼠标按下图标颜色
);

final closeButtonColors = WindowButtonColors(
  mouseOver: Color(0xFFD32F2F), // 关闭按钮悬停背景色 (红色)
  mouseDown: Color(0xFFB71C1C), // 关闭按钮按下背景色 (深红)
  iconNormal: Colors.black54, // 正常图标颜色
  iconMouseOver: Colors.white, // 悬停图标颜色 (白色)
);
