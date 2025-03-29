import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class SidebarWeb extends StatefulWidget {
  final List<String> sidebarItems;
  final String selectedItem;
  final Function(String) onItemSelected;
  final ScrollController scrollController;

  const SidebarWeb({
    super.key,
    required this.sidebarItems,
    required this.selectedItem,
    required this.onItemSelected,
    required this.scrollController,
  });

  @override
  State<SidebarWeb> createState() => _SidebarWebState();
}

class _SidebarWebState extends State<SidebarWeb> {
  bool _isVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final currentPosition = widget.scrollController.position.pixels;
    final maxScroll = widget.scrollController.position.maxScrollExtent;

    // Calculate scroll percentages
    final scrollPercentage = currentPosition / maxScroll;
    final isScrollingDown = currentPosition > _lastScrollPosition;

    setState(() {
      if (isScrollingDown) {
        // Original behavior for scrolling down - hide at 50%
        if (scrollPercentage >= 0.5) {
          _isVisible = false;
        }
      } else {
        // New behavior for scrolling up - show at 40%
        if (scrollPercentage <= 0.6) {
          _isVisible = true;
        }
      }
      _lastScrollPosition = currentPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isVisible ? 44 : -150, // Move off-screen when hidden
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 44, top: 155),
          child: Container(
            width: 150.0,
            height: 210.0,
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ...widget.sidebarItems.map((item) {
                        bool isSelected = item == widget.selectedItem;
                        return GestureDetector(
                          onTap: () {
                            widget.onItemSelected(item);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              item.toUpperCase(),
                              style: TextStyle(
                                fontFamily: GoogleFonts.barlow().fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.0,
                                letterSpacing: 1.5,
                                color:
                                    item == "SALE"
                                        ? const Color(0xFFF46856)
                                        : const Color(0xFF3E5B84),
                                background:
                                    item != "SALE" && isSelected
                                        ? (Paint()
                                          ..color = const Color(0xFFd3e4fd)
                                          ..style = PaintingStyle.fill)
                                        : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 22),
                      const Divider(color: Color(0xFF3E5B84), thickness: 1),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        'assets/Subtract.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        'assets/Icon.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
