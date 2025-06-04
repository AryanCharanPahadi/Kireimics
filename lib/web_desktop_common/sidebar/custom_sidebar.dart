import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:http/http.dart' as http;

import '../../component/utilities/url_launcher.dart';

class CustomSidebar extends StatefulWidget {
  final List<String> sidebarItems;
  final String selectedItem;
  final Function(String) onItemSelected;
  final ScrollController scrollController;

  const CustomSidebar({
    super.key,
    required this.sidebarItems,
    required this.selectedItem,
    required this.onItemSelected,
    required this.scrollController,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  bool _isVisible = true;
  double _lastScrollPosition = 0;
  String? _hoveredItem;
  Color? _iconColor1; // Default to null for the first icon
  Color? _iconColor2; // Default to null for the second icon

  String socialMediaLinks = '';
  String emailLink = '';
  String instagramLink = '';

  Future getSocialMediaLinks() async {
    final response = await http.get(
      Uri.parse(
        "https://vedvika.com/v1/apis/common/general_links/get_general_links.php",
      ),
    );

    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      setState(() {
        socialMediaLinks = data[0]['social_media_links'];
        instagramLink = jsonDecode(socialMediaLinks)['Instagram'];
        emailLink = jsonDecode(socialMediaLinks)['Email'];
      });
      // print(socialMediaLinks);
      // print(instagramLink);
      // print(emailLink);
    }
  }

  @override
  void initState() {
    super.initState();
    getSocialMediaLinks();
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

    final scrollPercentage = currentPosition / maxScroll;
    final isScrollingDown = currentPosition > _lastScrollPosition;

    setState(() {
      if (isScrollingDown) {
        if (scrollPercentage >= 0.5) {
          _isVisible = false;
        }
      } else {
        if (scrollPercentage <= 0.6) {
          _isVisible = true;
        }
      }
      _lastScrollPosition = currentPosition;
    });
  }

  // Function to launch URLs

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isVisible ? 44 : -150,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(left: isLargeScreen ? 140 : 44, top: 155),
          child: Container(
            width: isLargeScreen ? 140 : 150.0,
            height: 210.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ...widget.sidebarItems.map((item) {
                        bool isSelected = item == widget.selectedItem;
                        bool isHovered = item == _hoveredItem;
                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredItem = item),
                          onExit: (_) => setState(() => _hoveredItem = null),
                          child: GestureDetector(
                            onTap: () {
                              widget.onItemSelected(item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
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
                                      (item == "SALE" &&
                                              (isHovered || isSelected))
                                          ? (Paint()
                                            ..color = const Color(0xFFFFE5E5)
                                            ..style = PaintingStyle.fill)
                                          : (item != "SALE" &&
                                              (isHovered || isSelected))
                                          ? (Paint()
                                            ..color = const Color(0xFFd3e4fd)
                                            ..style = PaintingStyle.fill)
                                          : null,
                                ),
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
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _iconColor1 = Color(0xFF2876E4);
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _iconColor1 = null;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          UrlLauncherHelper.launchURL(
                            context,
                            instagramLink.toString(),
                          ); // Replace with your Instagram URL
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: SvgPicture.asset(
                            'assets/sidebar/instagram.svg',
                            width: 18,
                            height: 18,
                            color: _iconColor1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _iconColor2 = Color(0xFF2876E4);
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _iconColor2 = null;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          UrlLauncherHelper.launchURL(
                            context,
                            emailLink.toString(),
                          ); // Replace with your email address
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: SvgPicture.asset(
                            'assets/sidebar/email.svg',
                            width: 18,
                            height: 18,
                            color: _iconColor2,
                          ),
                        ),
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
