import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/components.dart';
import 'component/above_footer.dart';
import 'component/custom_footer.dart';
import 'component/custom_header.dart';
import 'component/custom_sidebar.dart';
import 'component/home_content.dart';
import 'component/home_content_new.dart';
import 'component/scrollable_header.dart';

class LandingPageWeb extends StatefulWidget {
  const LandingPageWeb({super.key});

  @override
  State<LandingPageWeb> createState() => _LandingPageWebState();
}

class _LandingPageWebState extends State<LandingPageWeb> {
  String _selectedItem = '';
  final List<String> _sidebarItems = ['Home', 'CATALOG', 'SALE', 'ABOUT'];
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _previousScrollOffset = 0.0;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_sidebarItems.isNotEmpty) {
      _selectedItem = _sidebarItems[0];
    }
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final currentScrollOffset = _scrollController.offset;
    const scrollThreshold = 50.0;

    if (currentScrollOffset > _previousScrollOffset &&
        currentScrollOffset > scrollThreshold) {
      if (_isHeaderVisible) {
        setState(() => _isHeaderVisible = false);
      }
    } else if (currentScrollOffset < _previousScrollOffset) {
      if (!_isHeaderVisible) {
        setState(() => _isHeaderVisible = true);
      }
    }

    _previousScrollOffset = currentScrollOffset;
  }

  void _onItemSelected(String item) {
    setState(() {
      _selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const ScrollableWebHeader(),
                  SizedBox(height: _isHeaderVisible ? 99 : 0),
                  Row(children: [_getContentForSelectedItem(_selectedItem)]),
                  const SizedBox(height: 5),
                  const CustomWebFooter(),
                ],
              ),
            ),
            // Positioned headers
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScrollingHeader(),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _isHeaderVisible ? 32 : -99,
              left: 0,
              right: 0,
              child: const CustomWebHeader(),
            ),
            SidebarWeb(
              sidebarItems: _sidebarItems,
              selectedItem: _selectedItem,
              onItemSelected: _onItemSelected,
              scrollController: _scrollController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContentForSelectedItem(String item) {
    switch (item) {
      case 'Home':
        return HomeContentNew();

      default:
        return const Expanded(child: HomeContentNew());
    }
  }
}
