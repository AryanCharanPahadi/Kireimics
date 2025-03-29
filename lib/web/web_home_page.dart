import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../component/components.dart';
import 'component/custom_footer.dart';
import 'component/custom_header.dart';
import 'component/custom_sidebar.dart';
import 'component/home_content.dart';
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
    super.dispose();
  }

  void _handleScroll() {
    final currentScrollOffset = _scrollController.offset;
    const scrollThreshold = 50.0;

    if (currentScrollOffset > _previousScrollOffset &&
        currentScrollOffset > scrollThreshold) {
      // Scrolling down
      if (_isHeaderVisible) {
        setState(() => _isHeaderVisible = false);
      }
    } else if (currentScrollOffset < _previousScrollOffset) {
      // Scrolling up
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
                  SizedBox(
                    height: _isHeaderVisible ? 99 : 0,
                  ), // Space for header when visible
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
              top:
                  _isHeaderVisible
                      ? 32
                      : -99, // 32 is height of ScrollingHeader
              left: 0,
              right: 0,
              child: const CustomWebHeader(),
            ),
            // In your LandingPageWeb build method, update the SidebarWeb instantiation:
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
        return Container(
          // color: Colors.blue,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start ,
            children: [
              Column(
                children: [
                  Container(
                    color: Colors.blue,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        // Background image (second image)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 590,
                            top: 17,
                            right: 90,
                          ),
                          child: Image.asset(
                            'assets/aquaCollection.png',
                            width: 699,
                            height: 373,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Foreground image (first image) that overlaps
                        Padding(
                          padding: const EdgeInsets.only(left: 380, top: 42),
                          child: SvgPicture.asset(
                            'assets/PanelTitle.svg',
                            width: 261,
                            height: 214,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.green,
                    child: Padding(
                      // Match the right padding of 90 from the aquaCollection image
                      padding: const EdgeInsets.only(left: 252, right: 90,top:30),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 23,
                              mainAxisSpacing: 23,
                            ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.pink,
                            width: 297,
                            height: 342,
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/plate.jpeg',
                                  width: 330,
                                  height: 350,
                                  fit: BoxFit.fitWidth,
                                ),
                                Positioned(
                                  top: 14,
                                  left: 15,
                                  right: 13,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(
                                        index == 1
                                            ? 'assets/off.svg'
                                            : 'assets/fewPiecesLeft.svg',
                                        height: 32,
                                        fit: BoxFit.contain,
                                      ),
                                      SvgPicture.asset(
                                        index == 1
                                            ? 'assets/IconWishlist.svg'
                                            : 'assets/IconWishlistEmpty.svg',
                                        // width: 34,
                                        height: 20,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                                if (index == 1)
                                  Positioned(
                                    bottom: 9,
                                    // top: 213,
                                    left: 8,
                                    right: 7,
                                    child: SizedBox(
                                      width: 282,
                                      height: 120,
                                      child: SvgPicture.asset(
                                        'assets/quickDetail.svg',
                                        fit: BoxFit.contain,
                                        width: 282,
                                        height: 120,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return const HomeContentWeb(); // Use the new HomeContent widget
    }
  }
}
