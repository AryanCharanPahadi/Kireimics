import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kireimics/web/component/above_footer.dart';

import 'component/aquacollection_card.dart';
import 'component/custom_header_mobile.dart';
import 'component/footer.dart';
import 'component/gridview.dart';
import 'component/let_connect.dart';
import 'component/scrolling_header.dart';

class LandingPageMobile extends StatefulWidget {
  const LandingPageMobile({super.key});

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile> {
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0.0;
  bool _isScrollingUp = false;
  bool _showStickyColumn1 = false;
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final isAtTop = currentOffset <= 0;
    final isPastThreshold = currentOffset > 100;

    _isScrollingUp = currentOffset > _lastScrollOffset;
    _lastScrollOffset = currentOffset;

    setState(() {
      if (isAtTop) {
        // At very top - show nothing sticky
        _showStickyColumn1 = false;
        _showStickyHeader = false;
      } else if (_isScrollingUp) {
        // Scrolling up - show only Column1
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = false;
      } else {
        // Scrolling down - show both
        _showStickyColumn1 = isPastThreshold;
        _showStickyHeader = isPastThreshold;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const ScrollingHeaderMobile(),
                CustomHeaderMobile(), // Original position
                Column1(), // Original position
                AquaCollectionCard(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(color: Color(0xFF3E5B84)),
                ),
                Gridview(),
                LetConnect(),
                const SizedBox(height: 24),
                AboveFooter(),
                const SizedBox(height: 27),
                Footer(),
              ],
            ),
          ),
          // Sticky headers when needed
          if (_showStickyHeader || _showStickyColumn1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white, // Background color for sticky headers
                child: Column(
                  children: [
                    if (_showStickyHeader) CustomHeaderMobile(),
                    if (_showStickyColumn1) Column1(),
                  ],
                ),
              ),
            ),
          // Sticky Chat Button
          Positioned(
            left: 300,
            bottom: 60,
            right: 10,
            child: SvgPicture.asset("assets/chat.svg", width: 36, height: 36),
          ),
        ],
      ),
    );
  }
}