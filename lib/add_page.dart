import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

// add页面
class AddPage extends StatefulWidget {
  final Map<String, dynamic>? defaultLibraryJson;
  final Map<String, dynamic>? userLibraryJson;
  final Map<String, dynamic>? filesJson;
  final void Function(Map<String, dynamic>, Map<String, dynamic>, bool) onLibraryJsonChanged;

  const AddPage({
    super.key,
    required this.defaultLibraryJson,
    required this.userLibraryJson,
    required this.filesJson,
    required this.onLibraryJsonChanged,
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic>? _defaultLibraryJson;
  late Map<String, dynamic>? _userLibraryJson;
  late Map<String, dynamic>? _filesJson;
  String _filePath = '';
  String _mainCategorySelectedKey = '';
  String _subCategorySelectedKey = '';
  String _publisher = '';
  DateTime _publishDate = DateTime.now();
  String _description = '';

  // 初始化
  @override
  void initState() {
    super.initState();
    _defaultLibraryJson = widget.defaultLibraryJson;
    _userLibraryJson = widget.userLibraryJson;
    _filesJson = widget.filesJson;
    _mainCategorySelectedKey = _defaultLibraryJson?.keys.first ?? '';
    _subCategorySelectedKey = _defaultLibraryJson?[_mainCategorySelectedKey]['files'].keys.first ?? '';
  }

  // 提交表单
  Future<void> _submitForm(String libraryPath, bool user) async {
    await _submitAddFile(libraryPath, user);
    // if (_filePath.isNotEmpty) {
    //   if (_formKey.currentState!.validate()) {
    //     await _submitAddFile(libraryPath, user);
    //     _formKey.currentState!.save();
    //   }
    // }
  }

  // 添加文件
  Future<void> _submitAddFile(String libraryPath, bool user) async {
    if (_filePath.isEmpty) {
      return;
    }
    // 读取文件并计算md5
    File file = File(_filePath);
    var fileBytes = await file.readAsBytes();
    String md5Hash = md5.convert(fileBytes).toString();
    // 创建文件夹并复制文件
    String targetDirPath = path.join(libraryPath, md5Hash);
    Directory targetDir = Directory(targetDirPath);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      String fileName = path.basename(_filePath);
      String targetFilePath = path.join(targetDirPath, fileName);
      await file.copy(targetFilePath);

      // 创建info.json
      Map<String, dynamic> fileInfo = {
        'originalName': fileName,
        'md5': md5Hash,
        'mainCategory': _mainCategorySelectedKey,
        'subCategory': _subCategorySelectedKey,
        'publisher': _publisher,
        'publishDate': _publishDate.toIso8601String(),
        'description': _description,
      };
      String jsonFilePath = path.join(targetDirPath, 'info.json');
      File jsonFile = File(jsonFilePath);
      await jsonFile.writeAsString(json.encode(fileInfo));
      //更新filesJson
      _filesJson![md5Hash] = fileInfo;
      // 更新library.json
      if (!user) {
        _defaultLibraryJson![_mainCategorySelectedKey]['files'][_subCategorySelectedKey]['subfiles'][md5Hash] =
            fileName;
        widget.onLibraryJsonChanged(_defaultLibraryJson!, _filesJson!, user);
      } else {
        _userLibraryJson![_mainCategorySelectedKey]['files'][_subCategorySelectedKey]['subfiles'][md5Hash] = fileName;
        widget.onLibraryJsonChanged(_userLibraryJson!, _filesJson!, user);
      }
    }
    // TODO: 若重复添加文件夹，则不进行后续操作
    else {}
  }

  // 选择文件
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.first.path ?? '';
      });
    }
  }

  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _publishDate) {
      setState(() {
        _publishDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> subCategory = _defaultLibraryJson?[_mainCategorySelectedKey]['files'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件夹选择
              Row(
                children: [
                  ElevatedButton(onPressed: null, child: Text('选择文件夹...')),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: '已选择文件夹', border: OutlineInputBorder()),
                      controller: TextEditingController(text: _filePath),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 文件选择
              Row(
                children: [
                  ElevatedButton(onPressed: _pickFile, child: Text('选择文件...')),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: '已选择文件', border: OutlineInputBorder()),
                      controller: TextEditingController(text: _filePath),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 文件分类选择
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(labelText: '分类', border: OutlineInputBorder()),
                      value: _mainCategorySelectedKey,
                      items:
                          _defaultLibraryJson?.entries.map((entry) {
                            return DropdownMenuItem(value: entry.key, child: Text(entry.value['title']));
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _mainCategorySelectedKey = value ?? '';
                          _subCategorySelectedKey =
                              _defaultLibraryJson?[_mainCategorySelectedKey]['files'].keys.first ?? '';
                        });
                      },
                      onSaved: (value) => _mainCategorySelectedKey = value ?? '',
                    ),
                  ),
                  SizedBox(width: 20),

                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(labelText: '子分类', border: OutlineInputBorder()),
                      value: _subCategorySelectedKey,
                      items:
                          subCategory.entries.map((entry) {
                            return DropdownMenuItem(value: entry.key, child: Text(entry.value['title']));
                          }).toList(),
                      onChanged: (String? newKey) {
                        setState(() {
                          _subCategorySelectedKey = newKey ?? '';
                        });
                      },
                      onSaved: (value) => _subCategorySelectedKey = value ?? '',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 发布人及时间
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: '发布人', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入发布人';
                        }
                        return null;
                      },
                      onSaved: (value) => _publisher = value ?? '',
                    ),
                  ),
                  SizedBox(width: 20),

                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '发布日期',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(text: "${_publishDate.toLocal()}".split(' ')[0]),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 说明
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(labelText: '说明', border: OutlineInputBorder()),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 20),

              // 提交
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _submitForm('library/user', true);
                    },
                    child: Text('添加'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm('library/default', false);
                    },
                    child: Text('添加并发布'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 结束
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
