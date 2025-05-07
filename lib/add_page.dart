import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// add页面
class AddPage extends StatefulWidget {
  const AddPage({super.key});  

  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  String _filePath = '';
  String _mainCategory = '';
  String _subCategory = '';
  String _publisher = '';
  DateTime _publishDate = DateTime.now();
  String _description = '';

  final List<String> _mainCategories = ['分类一', '分类二', '分类三']; // 示例数据
  final List<String> _subCategories = ['子类A', '子类B', '子类C']; // 示例数据

  // 选择文件
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.first.path ?? '';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime(2025),  
      lastDate: DateTime(2099)    
    );
    if (picked != null && picked != _publishDate)
      setState(() {
        _publishDate = picked;
      });
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // 在这里处理表单提交逻辑，例如打印数据或发送到服务器
      print('文件路径: $_filePath');
      print('主类别: $_mainCategory');
      print('子类别: $_subCategory');
      print('发布人: $_publisher');
      print('发布日期: $_publishDate');
      print('说明: $_description');
      // 可以在这里添加上传文件的逻辑
    }
  }

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 调用super的方法.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 文件选择
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: '文件', border: OutlineInputBorder()),
                      controller: TextEditingController(text: _filePath), // 显示文件路径
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择文件';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _pickFile, child: Text('选择文件')),
                ],
              ),
              SizedBox(height: 20),

              // 主类别
              DropdownButtonFormField<String>(
                value: _mainCategory = '分类一',
                onChanged: (String? newValue) {
                  setState(() {
                    _mainCategory = newValue!;
                  });
                },
                items: _mainCategories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: '主类别', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择主类别';
                  }
                  return null;
                },
                onSaved: (value) => _mainCategory = value ?? '',
              ),
              SizedBox(height: 20),

              // 子类别
              DropdownButtonFormField<String>(
                value: _subCategory = '子类A',
                onChanged: (String? newValue) {
                  setState(() {
                    _subCategory = newValue!;
                  });
                },
                items: _subCategories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: '子类别', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择子类别';
                  }
                  return null;
                },
                onSaved: (value) => _subCategory = value ?? '',
              ),
              SizedBox(height: 20),

              // 发布人
              TextFormField(
                decoration: InputDecoration(labelText: '发布人', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入发布人';
                  }
                  return null;
                },
                onSaved: (value) => _publisher = value ?? '',
              ),
              SizedBox(height: 20),

              // 发布日期
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '发布日期',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: "${_publishDate.toLocal()}".split(' ')[0],
                      ), // 显示日期
                      onTap: () => _selectDate(context), // 点击弹出日期选择器
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择发布日期';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('选择日期'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 说明
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(labelText: '说明', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入说明';
                  }
                  return null;
                },
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 20),

              // 添加按钮
              ElevatedButton(onPressed: _submitForm, child: Text('添加')),
            ],
          ),
        ),
      ),
    );
  }
}
