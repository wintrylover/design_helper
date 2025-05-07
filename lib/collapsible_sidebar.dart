import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 侧边导航栏
class CollapsibleSidebar extends StatefulWidget {
  final Map<String, dynamic>? configJson;
  final void Function(int) onItemTapped;

  const CollapsibleSidebar({super.key, required this.configJson, required this.onItemTapped});

  @override
  CollapsibleSidebarState createState() => CollapsibleSidebarState();
}

class CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _isExpanded = true;
  int _selectedIndex = 0;
  final double _expandedWidth = 230.0;
  final double _collapsedWidth = 70.0;
  Map<String, dynamic> _navigationItems = {};
  List<dynamic> _navigationItemsList = [];

  @override
  void initState() {
    super.initState();
    _navigationItems = widget.configJson?['CollapsibleSidebar']['navigationItems'] ?? {};
    _navigationItemsList = _navigationItems.values.toList();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? _expandedWidth : _collapsedWidth,
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Column(
        children: [
          Container(
            height: 80.0,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: _isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (_isExpanded)
                  Text(
                    widget.configJson?['applicationTitle'],
                    style: GoogleFonts.notoSansSc(fontSize: 20.0, fontWeight: FontWeight.w900),
                  ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu, color: Colors.black54),
                  onPressed: _toggleSidebar,
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[300]),

          // 导航菜单项列表区域
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._navigationItemsList.sublist(0, _navigationItemsList.length - 2).map((navigationItem) {
                  int index = navigationItem['index'];
                  String title = navigationItem['title'];
                  IconData icon = _getIconData(navigationItem['icon']);
                  return _buildNavigationItem(index, icon, title);
                }),
                Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                _buildNavigationItem(
                  _navigationItemsList[_navigationItemsList.length - 2]['index'],
                  _getIconData(_navigationItemsList[_navigationItemsList.length - 2]['icon']),
                  _navigationItemsList[_navigationItemsList.length - 2]['title'],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          _buildNavigationItem(
            _navigationItemsList.last['index'],
            _getIconData(_navigationItemsList.last['icon']),
            _navigationItemsList.last['title'],
          ),
        ],
      ),
    );
  }

  // 导航菜单图标
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'difference':
        return Icons.difference;
      case 'photo_library':
        return Icons.photo_library;
      case 'description':
        return Icons.description;
      case 'newspaper':
        return Icons.newspaper;
      case 'data_object':
        return Icons.data_object;
      case 'queue':
        return Icons.queue;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.help;
    }
  }

  // 构建单个导航菜单项
  Widget _buildNavigationItem(int index, IconData icon, String title) {
    // 对选中菜单修改其颜色是否选中
    bool isSelected = _selectedIndex == index;
    Color itemColor = isSelected ? Theme.of(context).primaryColor : Colors.black54;
    Color? backgroundColor = isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null;

    // 导航菜单
    return InkWell(
      // 单击操作，_selectedIndex为CollapsibleSidebar的属性，用于单击时的显示状态调整，widget.onItemTapped为回调，将选中的index传递给MyHomePage
      onTap: () {
        _selectedIndex = index;
        widget.onItemTapped(index);
      },
      child: Container(
        color: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _collapsedWidth,
              alignment: Alignment.center,
              child: Icon(icon, color: itemColor),
            ),
            if (_isExpanded)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    title,
                    style: TextStyle(color: itemColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
