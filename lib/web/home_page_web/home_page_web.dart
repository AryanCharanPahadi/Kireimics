import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/app_routes/routes.dart';
import '../../component/text_fonts/custom_text.dart';
import '../../component/custom_text_form_field/custom_text_form_field.dart';
import '../../component/product_details/product_details_controller.dart';
import '../../component/title_service.dart';
import '../../component/utilities/utility.dart';
import '../../web_desktop_common/collection/collection_modal.dart';
import '../../web_desktop_common/component/rotating_svg_loader.dart';
import '../../web_desktop_common/home_page_gridview/product_gridview_homepage.dart';
import '../../component/above_footer/above_footer.dart';

class HomePageWeb extends StatefulWidget {
  final Function(String)? onWishlistChanged;
  final Function(String)? onErrorWishlistChanged;
  const HomePageWeb({
    super.key,
    this.onWishlistChanged,
    this.onErrorWishlistChanged,
  });
  @override
  State<HomePageWeb> createState() => _HomePageWebState();
}

class _HomePageWebState extends State<HomePageWeb>
    with SingleTickerProviderStateMixin {
  // Track wishlist state
  late AnimationController _controller;
  late Animation<double> _animation;
  final ProductController productController = Get.put(ProductController());
  final FocusNode _messageFocusNode = FocusNode();
  final FocusNode _anotherMessageFocusNode = FocusNode();
  // Track hover state for image
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
  bool isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _anotherMessageController.dispose();
    _messageFocusNode.dispose();
    _anotherMessageFocusNode.dispose();
    super.dispose();
  }

  bool isSubmitting = false; // New flag to track form submission

  Future<void> _submitForm() async {
    final String formattedDate = getFormattedDate();

    // Validation checks
    if (_nameController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your name');
      return;
    }

    if (_emailController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      widget.onErrorWishlistChanged?.call('Please enter a valid email');
      return;
    }

    if (_messageController.text.isEmpty) {
      widget.onErrorWishlistChanged?.call('Please enter a message');
      return;
    }

    setState(() {
      isSubmitting = true; // Show loader
    });

    try {
      final response = await ApiHelper.contactQuery(
        name: _nameController.text,
        email: _emailController.text,
        message: "${_messageController.text} ${_anotherMessageController.text}",
        createdAt: formattedDate,
      );

      if (response['error'] == true) {
        widget.onErrorWishlistChanged?.call(
          response['message'] ?? 'Submission failed',
        );
      } else {
        widget.onWishlistChanged?.call('Form submitted successfully!');

        // Clear fields
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        _anotherMessageController.clear();
      }
    } catch (e) {
      widget.onErrorWishlistChanged?.call(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setState(() {
        isSubmitting = false; // Hide loader
      });
    }
  }

  String bannerImg = '';
  String bannerText = '';
  String bannerQuantity = '';
  int? bannerId;

  Future getCollectionBanner() async {
    try {
      List<CollectionModal> collections =
          await ApiHelper.fetchCollectionBanner();

      if (collections.isNotEmpty) {
        final bannerData = collections.first;

        // Safely handle empty or null product_id
        List<String> productIds = [];
        if (bannerData.productId != null &&
            bannerData.productId!.trim().isNotEmpty) {
          productIds = bannerData.productId!.split(',');
        }

        setState(() {
          bannerImg = bannerData.bannerImg ?? '';
          bannerText = bannerData.name ?? '';
          bannerId = bannerData.id;
          bannerQuantity = productIds.length.toString();
        });
      } else {
        // print("No collection data found.");
      }
    } catch (e) {
      // print('Error: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    TitleService.setTitle("Kireimics | Premium Handmade Ceramics in India");

    _initializeWishlistStates();
    getCollectionBanner();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Faster for hover effect
    );

    _animation = Tween<double>(
      begin: 1.0, // Start at normal scale
      end: 1.1, // Zoom in slightly on hover
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Initial animation for page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Background sticky container
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
                            right: screenWidth * 0.06,
                            left: screenWidth * 0.20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                        nextController:
                                            _anotherMessageController, // REQUIRED
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      child: CustomTextFormField(
                                        hintText: "",
                                        controller: _anotherMessageController,
                                        focusNode: _anotherMessageFocusNode,
                                        maxLength: 100,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    GestureDetector(
                                      onTap:
                                          isSubmitting
                                              ? null
                                              : _submitForm, // Disable tap during submission
                                      child:
                                          isSubmitting
                                              ? RotatingSvgLoader(
                                                size: 20,
                                                assetPath:
                                                    'assets/footer/footerbg.svg',
                                              )
                                              : BarlowText(
                                                text: "SUBMIT",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                lineHeight: 1.0,
                                                letterSpacing: 0.64,
                                                backgroundColor: Color(
                                                  0xFFb9d6ff,
                                                ),
                                                enableHoverBackground: true,
                                                color: Color(0xFF30578E),
                                                hoverTextColor: Color(
                                                  0xFFb9d6ff,
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CralikaFont(
                                        text: "LET'S CONNECT!",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32,
                                        letterSpacing: 0.04 * 32,
                                        color: Colors.white,
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.25,
                                        child: BarlowText(
                                          text:
                                              "Looking for gifting options, or want to get a piece commissioned? Let's connect and create something wonderful!",
                                          fontSize: 14,

                                          fontWeight: FontWeight.w400,
                                          lineHeight: 1.0,
                                          color: Colors.white,
                                          letterSpacing: 0.0,
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
                    double screenWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.4,
                            top: 17,
                            right: screenWidth * 0.07,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  height: screenWidth * 0.27,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: MouseRegion(
                                    onEnter: (_) {
                                      setState(() {});
                                      _controller.forward();
                                    },
                                    onExit: (_) {
                                      setState(() {});
                                      _controller.reverse();
                                    },
                                    child: AnimatedBuilder(
                                      animation: _animation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _animation.value,
                                          child:
                                              bannerImg.isNotEmpty
                                                  ? Image.network(
                                                    bannerImg,
                                                    width: screenWidth * 0.8,
                                                    height: screenWidth * 0.27,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null)
                                                        return child;
                                                      return Center(
                                                        child: RotatingSvgLoader(
                                                          assetPath:
                                                              'assets/footer/footerbg.svg',
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
                                                          child: RotatingSvgLoader(
                                                            assetPath:
                                                                'assets/footer/footerbg.svg',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  : Container(
                                                    color: Colors.grey[300],
                                                    child: Center(
                                                      child: RotatingSvgLoader(
                                                        assetPath:
                                                            'assets/footer/footerbg.svg',
                                                      ),
                                                    ),
                                                  ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.2,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white.withOpacity(0.8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: CralikaFont(
                                          text: bannerText,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                          lineHeight: 36 / 20,
                                          letterSpacing: 0.04 * 20,
                                          color: Color(0xFF30578E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: BarlowText(
                                          text: "$bannerQuantity Pieces",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          lineHeight: 1.0,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF30578E),
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
                                          color: const Color(0xFF30578E),
                                          enableHoverBackground: true,
                                          hoverBackgroundColor: Color(
                                            0xFF30578E,
                                          ),
                                          hoverTextColor: Colors.white,
                                          onTap: () async {
                                            context.go(
                                              "${AppRoutes.idCollectionView(bannerId!)}?collection_name=${bannerText}",
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
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 292,
                            top: 42,
                            right: screenWidth * 0.08,
                          ),
                          child: SvgPicture.asset(
                            'assets/home_page/PanelTitle.svg',
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.16,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.07,
                    left: 292,
                    top: 30,
                  ),
                  child: ProductGridView(
                    productController: productController,
                    onWishlistChanged: widget.onWishlistChanged,
                  ),
                ),
              ),
              const SizedBox(height: 313 + 200),
            ],
          ),
        ],
      ),
    );
  }
}
