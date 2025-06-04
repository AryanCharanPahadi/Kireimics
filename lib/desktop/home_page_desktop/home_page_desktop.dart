import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../component/above_footer/above_footer.dart';
import '../../component/cart_length/cart_loader.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/custom_text_form_field/custom_text_form_field.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/app_routes/routes.dart';
import '../../component/shared_preferences/shared_preferences.dart';
import '../../web_desktop_common/home_page_gridview/product_gridview_homepage.dart';
import '../../web_desktop_common/component/animation_gridview.dart';

class HomePageDesktop extends StatefulWidget {
  final Function(String)? onWishlistChanged; // Callback to notify parent
  final Function()? onPageLoaded; // Add this callback

  const HomePageDesktop({super.key, this.onWishlistChanged, this.onPageLoaded});
  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop>
    with SingleTickerProviderStateMixin {
  // Track wishlist state
  late AnimationController _controller;
  late Animation<double> _animation;
  final ProductController controller = Get.put(ProductController());
  late AnimationController _imageAnimationController;
  late Animation<double> _imageAnimation;
  bool _isImageHovered = false; // Track hover state for the main image
  List<bool> _isHoveredList = [];
  List<bool> _wishlistStates = [];

  void _initializeStates(int count) {
    if (_isHoveredList.length != count) {
      _isHoveredList = List.filled(count, false);
    }
    if (_wishlistStates.length != count) {
      _wishlistStates = List.filled(count, false);
    }
  }

  Future<void> _initializeWishlistStates() async {
    // This will be called after products are loaded
    if (mounted) setState(() {});
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _anotherMessageController =
      TextEditingController();
  FocusNode _messageFocusNode = FocusNode();
  FocusNode _anotherMessageFocusNode = FocusNode();

  String bannerImg = '';
  String bannerText = '';
  String bannerQuantity = '';
  int? bannerId;

  Future getCollectionBanner() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://vedvika.com/v1/apis/common/collection_list/get_collection_banner.php",
        ),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        // Access the first element of the 'data' array
        var bannerData = data['data'][0];

        // Split product_id string by commas and get the length
        List<String> productIds = bannerData['product_id'].toString().split(
          ',',
        );

        setState(() {
          bannerImg = bannerData['banner_img'].toString();
          bannerText = bannerData['name'].toString();
          bannerId = bannerData['id'];
          bannerQuantity = productIds.length.toString();
        });

        // print(bannerImg);
        // print(bannerText);
        // print(bannerQuantity);
      } else {
        print('Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _controller.dispose();
    _imageAnimationController.dispose();

    super.dispose();
  }

  void _submitForm() {
    // Check validation in order of priority
    if (_nameController.text.isEmpty) {
      widget.onWishlistChanged?.call('Please enter your name');
      return;
    }

    if (_emailController.text.isEmpty) {
      widget.onWishlistChanged?.call('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      widget.onWishlistChanged?.call('Please enter a valid email');
      return;
    }

    if (_messageController.text.isEmpty) {
      widget.onWishlistChanged?.call('Please enter a message');
      return;
    }

    // If all validations pass
    widget.onWishlistChanged?.call('Form submitted successfully!');
  }

  @override
  void initState() {
    super.initState();
    _initializeWishlistStates();
    getCollectionBanner();

    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Smooth transition
    );

    _imageAnimation = Tween<double>(
      begin: 1.0, // Normal scale
      end: 1.05, // Slightly zoomed in scale
    ).animate(
      CurvedAnimation(parent: _imageAnimationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onPageLoaded != null) {
        widget.onPageLoaded!(); // Notify that page has loaded
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Background sticky container moved first
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 313,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage(
                          "assets/home_page/background.png",
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF2472e3).withOpacity(0.9),
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;

                        return Padding(
                          padding: EdgeInsets.only(
                            top: 90,
                            right:
                                screenWidth * 0.15, // Responsive right padding
                            left: screenWidth * 0.3, // Responsive left padding
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end, // Align all columns at the top
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      child: CustomTextFormField(
                                        hintText: "YOUR NAME",
                                        maxLength: 20,
                                        controller: _nameController,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      child: CustomTextFormField(
                                        hintText: "YOUR EMAIL",
                                        isEmail: true,
                                        controller: _emailController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      child: CustomTextFormField(
                                        hintText: "MESSAGE",
                                        controller: _messageController,
                                        isMessageField: true,
                                        focusNode: _messageFocusNode,
                                        nextFocusNode: _anotherMessageFocusNode,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      child: CustomTextFormField(
                                        hintText:
                                            "", // Empty hint text for continuation
                                        controller: _anotherMessageController,
                                        focusNode: _anotherMessageFocusNode,
                                        maxLength: 40,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ), // Space between the empty field and the button
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: GestureDetector(
                                        onTap: () {
                                          _submitForm();
                                        },
                                        child: BarlowText(
                                          text: "SUBMIT",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          lineHeight: 1.0,
                                          letterSpacing: 0.64,
                                          backgroundColor: Color(0xFFb9d6ff),
                                          enableHoverBackground: true,
                                          color: Color(0xFF30578E),
                                          hoverTextColor: Color(0xFFb9d6ff),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 78),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "LET'S CONNECT!",
                                        style: TextStyle(
                                          fontFamily: 'Cralika',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 32,
                                          letterSpacing: 0.04 * 32,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: Text(
                                          "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  AboveFooter(),
                ],
              ),
            ),
          ),

          // Scrollable content on top
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Fixed left padding (matches your original 20% of a reference width)
                    // Using 300px as a fixed value that matches your original 20% of ~1500px
                    const double fixedLeftPadding = 389.0;

                    // Right padding remains responsive (15% of screen width)
                    double rightPadding = constraints.maxWidth * 0.15;

                    // Calculate available space for the image
                    double availableSpace =
                        constraints.maxWidth -
                        fixedLeftPadding -
                        rightPadding -
                        261 -
                        20; // 261 is SVG width, 20 is spacing

                    // Calculate dynamic image width
                    const double maxImageWidth = 952.0;
                    double imageWidth;

                    if (constraints.maxWidth < 1400) {
                      imageWidth = availableSpace;
                    } else if (constraints.maxWidth <= 1875) {
                      // Scale between 1400 and 1875
                      imageWidth = availableSpace;
                    } else {
                      // Fixed width after 1875
                      imageWidth = maxImageWidth;

                      // Adjust right padding to maintain layout when image is fixed at 952px
                      rightPadding =
                          constraints.maxWidth -
                          fixedLeftPadding -
                          261 -
                          20 -
                          imageWidth;
                      rightPadding = rightPadding.clamp(
                        constraints.maxWidth * 0.05,
                        constraints.maxWidth * 0.15,
                      ); // Keep within reasonable bounds
                    }

                    // Ensure image doesn't exceed max width
                    imageWidth = imageWidth.clamp(0, maxImageWidth);

                    return Padding(
                      padding: EdgeInsets.only(
                        left: fixedLeftPadding,
                        right: rightPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/home_page/PanelTitle.svg',
                            width: 261,
                            height: 214,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 20), // Spacing between SVG and image
                          Stack(
                            children: [
                              ClipRRect(
                                child: AnimatedBuilder(
                                  animation: _imageAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _imageAnimation.value,
                                      child: Container(
                                        width: imageWidth,
                                        height: 373,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        child:
                                            bannerImg.isNotEmpty
                                                ? Image.network(
                                                  bannerImg,

                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value:
                                                            loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    (loadingProgress
                                                                            .expectedTotalBytes ??
                                                                        1)
                                                                : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: Center(
                                                        child: Text(
                                                          'Failed to load image',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                                : Container(
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Text(
                                                      'No image available',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  width: 282,
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white.withOpacity(0.8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          bannerText,
                                          style: TextStyle(
                                            fontFamily: 'Cralika',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20,
                                            height: 36 / 20,
                                            letterSpacing: 0.04 * 20,
                                            color: Color(0xFF0D2C54),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "$bannerQuantity Pieces",
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.barlow().fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                            color: Color(0xFF30578E),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: BarlowText(
                                          text: "VIEW",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          lineHeight: 1.0,
                                          letterSpacing: 0.04 * 16,
                                          color: const Color(0xFF0D2C54),
                                          enableHoverBackground: true,
                                          hoverBackgroundColor: Color(
                                            0xFF30578E,
                                          ),
                                          hoverTextColor: Colors.white,
                                          onTap: () async {
                                            context.go(
                                              AppRoutes.idCollectionView(
                                                bannerId!,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.15,
                    left: 389,
                    top: 30,
                  ),
                  child: ProductGridView(
                    productController: controller,
                    onWishlistChanged: widget.onWishlistChanged,
                  ),
                ),
              ),
              const SizedBox(
                height: 313 + 200,
              ), // Reserve space for sticky container + AboveFooter
            ],
          ),
        ],
      ),
    );
  }
}
