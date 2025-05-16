import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ShowPage extends StatefulWidget {
  final String mainCategory;
  final Map<String, dynamic>? defaultLibraryJson;
  final Map<String, dynamic>? userLibraryJson;
  final Map<String, dynamic>? filesJson;

  const ShowPage({
    super.key,
    required this.mainCategory,
    required this.defaultLibraryJson,
    required this.userLibraryJson,
    required this.filesJson,
  });

  @override
  State<ShowPage> createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPage> {
  late String _mainCategory;
  late Map<String, dynamic>? _defaultLibraryJson;
  late Map<String, dynamic>? _userLibraryJson;
  late Map<String, dynamic>? _filesJson;

  // 初始化
  @override
  void initState() {
    super.initState();
    _mainCategory = widget.mainCategory;
    _defaultLibraryJson = widget.defaultLibraryJson;
    _userLibraryJson = widget.userLibraryJson;
    _filesJson = widget.filesJson;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> defaultMainCategoryFilesJson = _defaultLibraryJson![_mainCategory]['files'];
    Map<String, dynamic> userMainCategoryFilesJson = _userLibraryJson![_mainCategory]['files'];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children:
                  defaultMainCategoryFilesJson.entries.map((defaultSubCategoryFilesJson) {
                    return _subCategoryFilesShow(
                      defaultSubCategoryFilesJson,
                      userMainCategoryFilesJson[defaultSubCategoryFilesJson.key],
                    );
                  }).toList(),
            ),
          ),
        ),
        Container(padding: EdgeInsets.all(16.0), child: Text('data')),
      ],
    );
  }
}

// 带标题的文件展示组件
// 通过遍历defaultMainCategoryFilesJson实现，对于userMainCategoryFilesJson是利用default的key值来索引，所以后续调用不同，
// defaultSubCategoryFilesJson是MapEntry，而userSubCategoryFilesJson是Map
// 据此，若要在user中添加新的分类，需要同步在default中添加，否则不会显示
Widget _subCategoryFilesShow(defaultSubCategoryFilesJson, userSubCategoryFilesJson) {
  // 如果没有文件则只返回标题
  if (defaultSubCategoryFilesJson.value['subfiles'].isEmpty && userSubCategoryFilesJson['subfiles'].isEmpty) {
    return Text(defaultSubCategoryFilesJson.value['title']);
  }
  // 有文件时返回标题及组件
  else {
    // 获得所有文件的md5及路径
    Map<String, dynamic> filesPath = {};
    print(defaultSubCategoryFilesJson.value['subfiles']);
    Map<String, dynamic> a = defaultSubCategoryFilesJson.value['subfiles'] ?? {};
    for (String key in defaultSubCategoryFilesJson.value['subfiles'].keys) {
      filesPath[key] = 'library/default/${defaultSubCategoryFilesJson.value['subfiles'][key]}';
    }

    userSubCategoryFilesJson['subfiles'].entries.map((e) {
      filesPath[e.key] = 'library/user/${e.value}';
    });

    // 按照文件名称排序
    // var sortedEntries = filesPath.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    // filesPath = Map.fromEntries(sortedEntries);

    // 根据文件类型获取对应的图标
    IconData _getIconForFile(FileSystemEntity file) {
      // 文件夹图标
      if (file is Directory) {
        return Icons.folder_rounded;
      }
      // 非文件夹图标
      else if (file is File) {
        // 获取文件扩展名并转为小写
        String extension = path.extension(file.path).toLowerCase();
        switch (extension) {
          case '.jpg':
          case '.jpeg':
          case '.png':
          case '.gif':
          case '.bmp':
          case '.webp':
            return Icons.image_rounded; // 图片文件图标
          case '.pdf':
            return Icons.picture_as_pdf_rounded; // PDF文件图标
          case '.doc':
          case '.docx':
            return Icons.description_rounded; // Word文档图标
          case '.xls':
          case '.xlsx':
            return Icons.table_chart_rounded; // Excel表格图标
          case '.ppt':
          case '.pptx':
            return Icons.slideshow_rounded; // PPT演示文稿图标
          case '.zip':
          case '.rar':
          case '.7z':
          case '.tar':
          case '.gz':
            return Icons.archive_rounded; // 压缩文件图标
          case '.txt':
            return Icons.article_outlined; // 文本文件图标
          case '.mp3':
          case '.wav':
          case '.ogg':
          case '.aac':
            return Icons.audiotrack_rounded; // 音频文件图标
          case '.mp4':
          case '.mov':
          case '.avi':
          case '.mkv':
            return Icons.video_library_rounded; // 视频文件图标
          default:
            return Icons.insert_drive_file_rounded; // 默认文件图标
        }
      }
      return Icons.help_outline_rounded; // 未知类型或错误时的图标
    }

    // // 处理单击事件：选中文件
    // void _onFileTap(FileSystemEntity file) {
    //   setState(() {
    //     // 更新当前选中的文件
    //     _selectedFile = file;
    //   });
    // }

    // // 处理双击事件：打开文件或进入文件夹
    // void _onFileDoubleTap(FileSystemEntity file) {
    //   if (file is Directory) {
    //     // 如果是文件夹，则加载该文件夹的内容
    //     _loadFiles(file.path);
    //   } else if (file is File) {
    //     // 如果是文件，则尝试使用系统默认应用打开它
    //     _openFileWithExternalApp(file.path);
    //   }
    // }

    // // 使用 open_filex 插件打开文件
    // Future<void> _openFileWithExternalApp(String filePath) async {
    //   final result = await OpenFilex.open(filePath); // 尝试打开文件
    //   // 根据打开结果给出反馈
    //   if (result.type != ResultType.done) {
    //     // 如果打开不成功 (例如没有合适的应用，或文件损坏等)
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法打开文件: ${result.message}')));
    //     print("打开文件 (${filePath}) 失败: ${result.message}");
    //   }
    // }

    return Column(
      children: [
        Text(defaultSubCategoryFilesJson.value['title']),
        SizedBox(
          height: 300,
          child: GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.8,
            ),
            itemCount: filesPath.length,
            itemBuilder: (content, index) {
              return GestureDetector(
                onTap: null,
                onDoubleTap: null,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help, size: 48.0),
                      SizedBox(height: 8.0),
                      Text(filesPath[filesPath.keys.toList()[index]], maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
