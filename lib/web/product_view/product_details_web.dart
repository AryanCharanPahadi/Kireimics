import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kireimics/component/custom_text.dart';
import 'package:kireimics/component/routes.dart';
import '../../component/api_helper/api_helper.dart';
import '../../component/product_details/pd.dart';
import '../../component/product_details/product_details_modal.dart';

class ProductDetailsWeb extends StatefulWidget {
  final int productId;

  const ProductDetailsWeb({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailsWeb> createState() => _ProductDetailsWebState();
}

class _ProductDetailsWebState extends State<ProductDetailsWeb> {
  Product? product;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      final fetchedProduct = await ApiHelper.fetchProductById(widget.productId);
      if (fetchedProduct != null) {
        setState(() {
          product = fetchedProduct;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Product not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3E5B84)));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
          top: 500, // Adjust this value based on your content height
          left: 0,
          right: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,

            child: Padding(
              padding: const EdgeInsets.only(left: 490),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/home_page/background.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF2472e3).withOpacity(0.9),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 230,
                    right: 100,
                    top: 35,
                    bottom: 41,
                  ),
                  child: Column(
                    children:
                        product!.otherDetails.map((detail) {
                          // You can optionally map specific titles to SVG icons
                          String iconPath;
                          switch (detail.title.toLowerCase()) {
                            case 'materials':
                              iconPath = 'assets/icons/material.svg';
                              break;
                            case 'product care':
                              iconPath = 'assets/icons/care.svg';
                              break;
                            case 'shipping':
                              iconPath = 'assets/icons/shipping.svg';
                              break;
                            default:
                              iconPath =
                                  'assets/icons/info.svg'; // default fallback icon
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: infoTile(
                              svgAssetPath: iconPath,
                              title: detail.title,
                              description: detail.description,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              // color: Colors.green,
              width: MediaQuery.of(context).size.width,

              child: Padding(
                padding: const EdgeInsets.only(
                  left: 292, // 40% of screen width
                  top: 25,
                  right: 100, // 7% of screen width
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BarlowText(
                          text: "Catalog",
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          letterSpacing: 1 * 0.04, // 4% of 32px
                        ),
                        SizedBox(width: 9.0),
                        SvgPicture.asset(
                          'assets/icons/right_icon.svg',
                          width: 24,
                          height: 24,
                          color: Color(0xFF3E5B84),
                        ),
                        SizedBox(width: 9.0),

                        BarlowText(
                          text: product!.catName,
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                        ),
                        SizedBox(width: 9.0),
                        SvgPicture.asset(
                          'assets/icons/right_icon.svg',
                          width: 24,
                          height: 24,
                          color: Color(0xFF3E5B84),
                        ),
                        SizedBox(width: 9.0),

                        BarlowText(
                          text: "View Details",
                          color: Color(0xFF3E5B84),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.0,
                          route: AppRoutes.productDetails(product!.id),
                          enableUnderlineForActiveRoute:
                          true, // Enable underline when active
                          decorationColor: Color(0xFF3E5B84), // Color of the underline
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Container(
                      // color: Colors.yellow,
                      // height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Image.network(
                                product!.thumbnail, // Use product image path
                                width: 370,
                                height: 444,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10),
                              Row(
                                children:
                                    product!.otherImages.map((imageUrl) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16.0,
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          width: 106,
                                          height: 122,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 106,
                                                    height: 122,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(width: 50),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                width: 400,
                                child: CralikaFont(
                                  text: product!.name,

                                  fontWeight: FontWeight.w400, // 400 weight
                                  fontSize: 32, // 32px
                                  lineHeight:
                                      36 /
                                      32, // Line height (36px) divided by font size (32px)
                                  letterSpacing: 32 * 0.04, // 4% of 32px
                                  color: Color(0xFF414141),
                                  softWrap: true,
                                ),
                              ),

                              SizedBox(height: 09.0),

                              BarlowText(
                                text: product!.catName,

                                fontWeight: FontWeight.w600, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                                color: Color(0xFF3E5B84),
                              ),

                              SizedBox(height: 14),

                              BarlowText(
                                text: product!.price,

                                fontWeight: FontWeight.w400, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                                color: Color(0xFF414141),
                              ),
                              SizedBox(height: 14),

                              BarlowText(
                                text: product!.dimensions,

                                fontWeight: FontWeight.w400, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                                color: Color(0xFF414141),
                              ),

                              SizedBox(height: 14),

                              SizedBox(
                                width: 508,

                                child: BarlowText(
                                  text: product!.description,

                                  fontWeight: FontWeight.w400, // 400 weight
                                  fontSize: 16, // 32px
                                  lineHeight: 1.0,
                                  letterSpacing: 1 * 0.04, // 4% of 32px
                                  color: Color(0xFF414141),
                                  softWrap: true,
                                ),
                              ),

                              SizedBox(height: 44),
                              BarlowText(
                                text: "ADD TO CART",
                                color: Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                                backgroundColor: Color(0xFFb9d6ff),

                              ),
                              SizedBox(height: 24),
                              BarlowText(
                                text: "WISHLIST",
                                color: Color(0xFF3E5B84),
                                fontWeight: FontWeight.w600, // 400 weight
                                fontSize: 16, // 32px
                                lineHeight: 1.0,
                                letterSpacing: 1 * 0.04, // 4% of 32px
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 200),
          ],
        ),
      ],
    );
  }

  Widget infoTile({
    required String svgAssetPath, // change from IconData to String
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: SvgPicture.asset(
            svgAssetPath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
